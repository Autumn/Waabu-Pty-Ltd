require 'couchrest'
require 'date'

module Waabu
  class Payment

    DB = CouchRest.database! "#{Waabu::DB_SERVER}/#{Waabu::PAYMENTS_DB}"

    include PayPal::SDK::REST

    PayPal::SDK.configure({
      :mode => Waabu::PAYPAL_MODE,
      :client_id => Waabu::PAYPAL_ID,
      :client_secret => Waabu::PAYPAL_SECRET
    })

    def self.bootstrap_db
      # create views
      search = {
	"id" => {"map"=>"function(doc){if(doc.id){emit(doc.id,doc);}}"},
	"paymentid" => {"map"=>"function(doc){if(doc.paymentid){emit(doc.paymentid,doc);}}"},
	"productid" => {"map"=>"function(doc){if(doc.productid){emit(doc.productid,doc);}}"},
	"user" => {"map"=>"function(doc){if(doc.user){emit(doc.user,doc);}}"},
	"type" => {"map"=>"function(doc){if(doc.type){emit(doc.type,doc);}}"},
	"state"=> {"map"=>"function(doc){if(doc.state){emit(doc.state,doc);}}"},
	"timecreated" => {"map"=>"function(doc){if(doc.timecreated){emit(doc.timecreated,doc);}}"},
	"timepaid" => {"map"=>"function(doc){if(doc.timepaid){emit(doc.timepaid,doc);}}"}
      }

      view = {"_id"=>"_design/search", "views"=>search}

      DB.save_doc view
    end

    def self.clean_db
      DB.get("_all_docs")["rows"].each do |row|
	DB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

    def self.create_payment user, type, cart 
      payment = {}
      payment[:type] = type
      payment[:id] = SecureRandom.uuid
      payment[:user] = user 
      payment[:timecreated] = DateTime.now.to_s
      payment[:timepaid] = nil
      payment[:amount] = Waabu::Cart.price_cart cart
      payment[:state] = "created"
      payment[:cart] = cart
      payment[:data] = {}

      if type == "bitcoin"
        Waabu::Log.info "Bitcoin payment created for #{user}"
        btc_payment = self.create_bitcoin_payment cart, payment[:id]
        payment[:data] = btc_payment[:data]
        DB.save_doc payment
        {:id => payment[:id], :url => btc_payment[:url], :qrcode => btc_payment[:qrcode], :amount=> btc_payment[:data][:amount], :address=> btc_payment[:data][:address]}
      elsif type == "paypal"
        Waabu::Log.info "Paypal payment created for #{user}"
        payment[:data] = self.create_paypal_payment cart, payment[:id]
        DB.save_doc payment
        {:id => payment[:id], :link => payment[:data][:redirect]}
      end
    end

    def self.get_payment id 
      payment = nil
      DB.view("search/id")["rows"].each do |row|
	payment = row["value"] if row["key"] == id
      end
      payment 
    end

    def self.get_all_payments user
      payments = []
      DB.view("search/user")["rows"].each do |row|
        if row["key"] == user
          payments.push row["value"]
        end
      end
      payments
    end

    # paypal and bitcoin payment specific code

    def self.create_paypal_payment cart, id
      # build payment
      payment = Waabu::Paypal.build_paypal_payment cart, id
      payment.create
      link = payment.links.find{|v| v.method == "REDIRECT"}.href
      data = {}
      data[:redirect] = link
      data[:id] = payment.id
      data
      # send payment to paypal and get callback url
      # return object with redirect url and data to save in db
    end

    def self.execute_paypal_payment id, payer_id
      payment_record = Waabu::Payment.get_payment id
      if payment_record != nil
        if payment_record["timepaid"] != nil
          Waabu::Log.warn "Attempt to replay Paypal payment #{payment_record["id"]}"
          return {:error => "already paid"}
        end
        paypal_id = payment_record["data"]["id"]
        paypal_payment = PayPal::SDK::REST::Payment.find paypal_id
        paypal_payment.execute(:payer_id => payer_id)
        self.on_executed_paypal_payment paypal_payment, payer_id, payment_record
      end
      # on paypal callback url
      # get payer id
      # search payment object from the uuid in callback
      # execute payment on paypal and store result
      # begin spinup on success
    end 

    def self.on_executed_paypal_payment payment, payer_id, record
      if payment.state == "pending" or payment.state == "approved"
        Waabu::Log.info "Paypal payment #{record["id"]} changed to #{payment.state}"
        record["state"] = payment.state
        record["timepaid"] = DateTime.now.to_s
        record["data"]["payer_id"] = payer_id
        DB.save_doc record
        # begin spinup
        self.spinup_items record
        {:error => "none"}
      elsif payment.state == "cancelled" or payment.state == "failed"
        record["state"] = payment.state
        DB.save_doc record
        {:error => "paypal payment failure"}
      end
    end

    def self.cancel_paypal_payment
      # mark payment as cancelled
    end

    def self.create_bitcoin_payment cart, id

      data = {}
      data[:privkey], data[:pubkey] = Bitcoin::generate_key
      data[:address] = Bitcoin::pubkey_to_address data[:pubkey]
      data[:amount] = Waabu::BTC.aud_to_bitcoin Waabu::Cart.price_cart(cart)
      url = "bitcoin:#{data[:address]}?amount=#{data[:amount]}"
      qrcode = Waabu::BTC.generate_qr url
      self.listen_bitcoin_payment id, data[:address], data[:amount]
      {:data => data, :url=> url, :qrcode => qrcode}   
    end

    def self.listen_bitcoin_payment id, address, amount
      scheduler = Rufus::Scheduler.new
      expected_satoshis = (amount * 100000000).round 0 
      Waabu::Log.info "Listening to address #{address} for #{expected_satoshis} satoshis for payment #{id}"
      scheduler.every '20s' do
        address_state = JSON.parse RestClient.get("http://blockchain.info/address/#{address}?format=json")
        balance = address_state["final_balance"]
        if balance >= expected_satoshis
          Waabu::Log.info "Received #{balance} satoshis at address #{address} for payment #{id}. Exceeds sufficient value of #{expected_satoshis} satoshis, commencing spinup."
          self.execute_bitcoin_payment id
          scheduler.shutdown
        elsif balance > 0
          Waabu::Log.info "Received #{balance} satoshis at address #{address} for payment #{id}. Not sufficient for spinup, amount required = #{expected_satoshis}"
        end
        # requires timeout to stop
      end
    end

    def self.execute_bitcoin_payment id
      payment = self.get_payment id
      payment["state"] = "approved"
      payment["timepaid"] = DateTime.now.to_s
      Waabu::Log.info "Bitcoin payment #{id} moved to approved"

      DB.save_doc payment
      self.spinup_items payment
      # called when amount detected in bitcoin address
      # sets payment state
      # forwards coins to storage addr
      # begin spinup
    end 

    # ----------------

    def self.spinup_items payment
      payment["cart"].each do |item|
         Thread.new {
         product = Waabu::Cart.search_product item["id"]
         sub_id = Waabu::Subscription.create_subscription payment["user"], payment["id"], item["id"], item["options"], item["subscription"], payment["timepaid"]
         Waabu::Log.info "Created subscription #{sub_id} for #{payment["user"]}"
         Waabu::Log.info "Beginning spinup for subscription #{sub_id}"
         Waabu::Spinup.spinup payment["user"], sub_id, item
         }
       # spin up
      end
    end

#    def self.payment_made id
#      payment = self.get_payment id
#      payment[:state] = "approved"
#      payment[:timepaid] = DateTime.now.to_s
#      DB.save_doc payment

#      payment["cart"].each do |item|
#        product = Waabu::Cart.search_product item["id"]
#        sub_id = Waabu::Subscription.create_subscription payment["user"], id, item["id"], item["options"], item["subscription"], payment[:timepaid]
#        Waabu::Spinup.spinup payment["user"], sub_id, item
	# register product under user as a subscription
        # spin up
#      end 
#    end
  end

  class Subscription
    DB = CouchRest.database! "#{Waabu::DB_SERVER}/#{Waabu::SUBSCRIPTIONS_DB}"

    def self.bootstrap_db
      search = { 
        "id" => {"map"=>"function(doc){if(doc.id){emit(doc.id,doc);}}"},
        "user" => {"map"=>"function(doc){if(doc.user){emit(doc.user,doc);}}"},
        "productid" => {"map"=>"function(doc){if(doc.productid){emit(doc.productid,doc);}}"},
        "paymentid" => {"map"=>"function(doc){if(doc.paymentid){emit(doc.paymentid,doc);}}"},
        "nextpayment"=> {"map"=>"function(doc){if(doc.nextpayment){emit(doc.nextpayment,doc);}}"},
        "paymentdate" => {"map"=>"function(doc){if(doc.paymentdate){emit(doc.paymentdate,doc);}}"},
      }   

      view = {"_id"=>"_design/search", "views"=>search}

      DB.save_doc view
    end

    def self.clean_db
      DB.get("_all_docs")["rows"].each do |row|
        DB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

    def self.create_subscription user, paymentid, productid, config, term, paymentdate
      subscription = {}
      subscription[:id] = SecureRandom.uuid
      subscription[:user] = user
      subscription[:productid] = productid
      subscription[:paymentid] = paymentid
      subscription[:config] = config
      subscription[:paymentdate] = paymentdate
      subscription[:nextpayment] = self.next_payment term, paymentdate
      subscription[:term] = term
      Waabu::Log.info "Created #{subscription} for #{user}"
      DB.save_doc subscription
      subscription[:id]
    end

    def self.next_payment term, date
      datepaid = DateTime.parse date
      nextpayment = nil
      if term == "monthly"
	nextpayment = datepaid >> 1
      elsif term == "yearly"
	nextpayment = datepaid >> 12
      end
      nextpayment.to_s
    end 

    def self.get_subscriptions user
      DB.view("search/user")["rows"].each do |row|

      end
    end

  end

  class Paypal 

    def self.build_paypal_payment cart, id
      item_list = self.build_paypal_itemlist cart
      total_price = Waabu::Cart.price_cart cart

      payment = PayPal::SDK::REST::Payment.new({
      :intent => "sale",
      :payer => {
       :payment_method => "paypal" },
      :redirect_urls => {
       :return_url => "#{Waabu::SITE_URL}/paidbypaypal?success=true&uuid=#{id}",
       :cancel_url => "#{Waabu::SITE_URL}/paidbypaypal?success=false&cancel=true&uuid=#{id}" },
      :transactions => [ {
       :amount => {
         :total => "#{total_price}",
         :currency => "AUD" },
       :item_list => {:items => item_list},
      :description => "Waabu Cloud Services" } ] } )
      payment     
    end

    def self.build_paypal_itemlist cart
      item_list = []
      cart.each do |item|
        product = Waabu::Cart.search_product item["id"]
        pp_item = {}
        pp_item["quantity"] = "1"
        pp_item["currency"] = "AUD"
        pp_item["name"] = "#{product["name"]} Subscription"
        pp_item["price"] = Waabu::Cart.price_item item
        item_list.push pp_item
      end
      item_list
    end
  end

  class BTC

    def self.get_btc_price
      ticker = "http://blockchain.info/ticker"
      prices = JSON.parse(RestClient.get ticker)
      Waabu::Log.info "Setting Bitcoin price to #{prices["AUD"]["buy"]}"
      prices["AUD"]["buy"]
    end

    SCHEDULER = Rufus::Scheduler.new
    AUD_PRICE = self.get_btc_price

    SCHEDULER.every '24h' do
      AUD_PRICE = self.get_btc_price
    end

    def self.aud_to_bitcoin price
      (price / AUD_PRICE.to_f).round 5
    end
   
    def self.generate_qr url
      img_url = "qrs/#{SecureRandom.uuid}.png"
      qrcode = RQRCode::QRCode.new(url, :size=>8, :level=>:h)
      png = qrcode.to_img
      png.resize(300,300).save("app/#{img_url}")
      img_url
    end

  end
end
