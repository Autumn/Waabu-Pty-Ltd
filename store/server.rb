require 'sinatra'
require 'rufus/scheduler'

require 'waabu'

require 'rest-client'

$payment_session = Hash.new
$payment_complete = Hash.new

MINUTES = 15
SECONDS = 60
EXPIRES_IN = MINUTES * SECONDS 

set :protection, :origin_whitelist => ['https://waabu.com', 'https://www.waabu.com']

before do
  cache_control :private, :must_revalidate, :max_age => 0
end

not_found do
  status 404
  erb :oops
end

$sessions = Hash.new
$scheduler = Rufus::Scheduler.new

$scheduler.every '1m' do
   if $sessions != nil
     $sessions.each_key do |uuid|
       next if $sessions[uuid] == nil
       if Time.now > $sessions[uuid][:expires]
          puts "expiring session for #{$sessions[uuid]}"
          $sessions[uuid] = nil
       end
     end
   end
end

def login_user(email, password)
   user = Waabu::Accounts.get_details(email)
   if user[:error] != "user not found"  
      if Waabu::Accounts.authenticate_user email, password
         true
      else
         false
      end
   else
      false
   end
end

def check_valid_email(email)
  puts "#{email}"
  if Waabu::Validator.validate_email(email)[:valid]
    true
  else 
    false
  end
end

def start_session(uuid, email)
   $sessions[uuid] = {:user => email, :expires => Time.now + (EXPIRES_IN)}
   {"session" => uuid}.to_json
end

get '/' do
  erb :index
end

post '/register' do
   puts request.referrer
   email = params[:username]
   pw = params[:password]
   if check_valid_email(email) == false
      {"error" => "invalid email"}.to_json
   elsif Waabu::Accounts.search_user(email) != false
      {"error" => "registration failed"}.to_json
   else
      Waabu::Accounts.register_user email, pw
      # send email
      `ssh -i ~/.ssh/id_email root@103.228.135.246 sh send-welcome-email.sh #{email}`
      start_session(SecureRandom.uuid.to_s, email)
   end
end

post '/login' do
   email = params[:username]
   pw = params[:password]
   if login_user(email, pw)
      start_session(SecureRandom.uuid.to_s, email)
   else
      {"error" => "login failed"}.to_json
   end
end

get '/paid' do
   if params["success"] == "true" and params["PayerID"] != nil and params["uuid"] != nil
     # perform payment
     payer_id = params["PayerID"]
     payment = Waabu::Payment.get_paypal_payment_from_uuid params["uuid"]
     if payment[:error] == nil
       payment_id = payment[:id]
      # Waabu::Payment.execute_paypal_payment payment[:payment], payment_id
       execute_payment = Waabu::Payment.execute_paypal_payment_from_uuid params["uuid"], payer_id 
       if execute_payment[:error] == "none"
        puts "#{params["uuid"]} PAID"
         session = $payment_session[payment_id]
         $payment_complete[session] = true
#         execute_payment.to_s
         erb :paid_success
       else
         "error"
       end
     else 
       ""
     end
   elsif params["success"] == "false" or params["cancel"] == "true"
      erb :paid_failed
   end
end

get '/paid-by-bitcoin' do
  if params[:uuid] != nil
  uuid = params[:uuid]
  doc = nil
  $BTC_DB.view("search/uuid")["rows"].each do |row|
    if row["key"] == uuid
      doc = row["value"]
    end 
  end
  return {:error => "invalid transaction"}.to_json if doc == nil
  doc
  time = Time.now
  doc[:time_paid] = time
  doc[:status] = "paid"
  $BTC_DB.save_doc doc
  session = $payment_session[uuid]
  puts "sale of session #{session} completed"
  $payment_complete[session] = true
  
# search for payment
# if exists
# mark as success
# record in db
# start spinup
  else
    {:error => "invalid transaction"}.to_json
  end
end

post '/check_payment' do
  puts "#{$payment_complete}"
  puts "#{params["session"]}"
  session = request.body.read
  if $payment_complete[session] == true
    $payment_complete[session] = nil
    {:complete => true}.to_json
  else
    {:complete => false}.to_json
  end
end

$BTC_DB = CouchRest.database "http://172.24.0.7:5984/bitcoin_payments"

post '/pay-bitcoin' do
  if $sessions[params["session"]] != nil
    cart = JSON.parse URI.decode(params["cart"])
    email = $sessions[params["session"]][:user]
    price = Waabu::Cart.price_cart cart
    time = Time.now
    if price[:error] == nil
      uuid = SecureRandom.uuid
      payment = {:uuid => uuid, :price => price, :time_created => time, :time_paid => nil, :cart => cart, :email => email, :state => "created"}
      $BTC_DB.save_doc payment
      $payment_session[uuid] = params["session"]
      $payment_complete[params["session"]] = false

      # record transaction in db with cart
      # connect to local bitcoin client and get data
      btc_payment = JSON.parse(RestClient.get "localhost:5000/?value=#{price[:price]}&uuid=#{uuid}")
      btc_payment.to_json
    else
      {:error => "invalid cart"}.to_json
    end
  else 
    {:error => "not logged in"}.to_json
  end
end

post '/pay' do
   if $sessions[params["session"]] != nil

    cart = JSON.parse params["cart"]
    puts "#{cart}"
    email = $sessions[params["session"]][:user]

    payment = Waabu::Payment.create_paypal_payment email, cart

# set up listener for payment completiton
  
    $payment_session[payment.id] = params["session"]
    $payment_complete[params["session"]] = false
#
    payment.create

    link = payment.links.find{|v| v.method == "REDIRECT"}.href      
    redirect link
   else
     "error not logged in"
   end
end

get '/products' do
  Waabu::Store.get_products.to_json
end

post '/email-validate' do
  Waabu::Validator.validate_email(request.body.read).to_json
end

post '/ssh-validate' do
   Waabu::Validator.validate_sshkey(request.body.read).to_json
end

post '/session-validate' do
  if $sessions[params["session"]] != nil
    {"valid" => true}.to_json
  else
    {"valid" => false}.to_json
  end   
end

get '/soldout' do
  begin
    response = RestClient.get 'localhost:8999'
  rescue => e
    response = "no"
  end
  puts "#{response}"
  response
end

get '/comingsoon' do
  begin
    response = RestClient.get 'localhost:8998'
  rescue => e
    response = "no"
  end
  puts "#{response}"
  response
end
