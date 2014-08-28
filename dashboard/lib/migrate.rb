require 'couchrest'
require 'json'
require 'date'
require 'securerandom'

accounts_old = CouchRest.database "http://172.24.0.7:5984/accounts"
accounts_new = CouchRest.database "http://172.24.0.7:5984/accounts_prod"

#accounts_old.view("check_email/query")["rows"].each do |row|
#  accounts_new.save_doc({:email => row["value"]["email"], :hash => row["value"]["hash"], :salt => row["value"]["salt"]})
#end

db = "http://172.24.0.7:5984"
payments_old = CouchRest.database "#{db}/payments"
payments_new = CouchRest.database "#{db}/payments_prod"

subscriptions = CouchRest.database "#{db}/subscriptions_prod"
vms_old = CouchRest.database "#{db}/vms"
vms_new = CouchRest.database! "#{db}/vms_prod"


payments_old.view("search/email")["rows"].each do |row|
  # time_craeted => timecreated
  # time_paid => timepaid
  # items => cart
  if row["value"]["state"] == "approved"
    new = {}
    new[:id] = row["value"]["uuid"]
    new[:user] = row["value"]["email"]
    new[:type] = "paypal"
    new[:timecreated] = DateTime.parse(row["value"]["time_created"]).to_s
    new[:timepaid] = DateTime.parse(row["value"]["time_paid"]).to_s
    new[:data] = {}
    new[:data][:id] = row["value"]["id"]
    new[:data][:payer_id] = nil
    new[:state] = "approved"
    new[:amount] = row["value"]["total"]
 
    items = row["value"]["items"]
    new[:cart] = []
    items.each do |item|
      new_item = {}
      new_item[:id] = "818174b9-6b67-4a2a-ad2a-2740a068fdb8"
      new_item[:options] = {}
      new_item[:options][:os] = item["os"]
      new_item[:subscription] = item["subscription"]
      new_item[:options][:upgrades] = {}
      new_item[:options][:sshkey] = ""
      new[:cart].push new_item

      # generate subscriptions based on cart
      subscription = {}
      subscription[:id] = SecureRandom.uuid
      subscription[:user] = new[:user]
      subscription[:productid] = new_item[:id]
      subscription[:paymentid] = new[:id]
      subscription[:config]  = {}
      subscription[:paymentdate] = new[:timepaid]
 nextpayment = new[:timepaid]
      subscription[:nextpayment] = (DateTime.parse(nextpayment) >> 1).to_s 
 
      subscription[:term] = item["subscription"]
  
      subscriptions.save_doc subscription

      vms_old.view("list/email")["rows"].each do |vmrow| 
        if row["key"] == new[:user]
        vm= {}

        vm[:name] = vmrow["value"]["item"]["name"]
        vm[:subscriptionid] = subscription[:id]
        vm[:user] = vmrow["value"]["email"] 
        vm[:vmconf] = {}
        vm[:vmconf][:vmid] = vmrow["value"]["vmid"]
        vm[:vmconf][:sshkey] = vmrow["value"]["item"]["sshkey"]
        vm[:vmconf][:cpu] = vmrow["value"]["item"]["cpu"]
        vm[:vmconf][:ram] = vmrow["value"]["item"]["ram"]
        vm[:vmconf][:storage] = vmrow["value"]["item"]["storage"]
        vm[:vmconf][:storagetype] = vmrow["value"]["item"]["storagetype"]
        vm[:vmconf][:os] =  vmrow["value"]["vm"]["os"]
        vm[:vmconf][:vlan] = vmrow["value"]["vlan"]
        vm[:vmconf][:ipv4] = vmrow["value"]["ipv4"]
        vm[:vmconf][:ipv6] = vmrow["value"]["ipv6"]
        vms_new.save_doc vm
        end
#{"_id"=>"c10aa1b8cdc7c04b4da365057a8faedf", "_rev"=>"1-93e64aac9014afd2eaab164512c47cc3", "email"=>"aarthmi_01@yahoo.com.au", "vmid"=>
#"24866ba5-69f1-0951-78f0-213867e9d961", "item"=>{"os"=>"ubuntu-14.04-32", "sshkey"=>"", "ram"=>512, "cpu"=>2, "storage"=>10, "storage_
#type"=>"ssd", "name"=>"aarthmi_01@yahoo.com.au:BaseWaab"}, "vm"=>{"os"=>"ssd-ubuntu-14.04-32", "ram"=>"512MiB", "storage"=>"10GiB", "c
#pu"=>2, "name"=>"aarthmi_01@yahoo.com.au:BaseWaab"}, "ipv4"=>"103.228.132.5", "ipv6"=>"2400:d080:8000::5", "vlan"=>"30"}


  # create vmconf from item description
  # get subscription id
       end

      payments_new.save_doc new

    end
    # convert cart to new format new[:cart] 

  end

#"email"=>"aarthmi_01@yahoo.com.au", "uuid"=>
#"7c5c10cf-8f40-40ae-b65c-ebe96b4811df", "time_created"=>"2014-05-07 09:17:17 +0000", "time_paid"=>"2014-05-07 09:28:37 +0000", "timeou
#t"=>nil, "id"=>"PAY-4TJ51062BY069924YKNU7UII", "state"=>"approved", "total"=>"9.00", "items"=>[{"name"=>"BaseWaab", "os"=>"ubuntu-14.0
#4-32", "sshkey"=>"", "upgrades"=>[], "subscription"=>"monthly", "$$hashKey"=>"00K"}]}
  # create appropriate subscription object
end
ips_old = CouchRest.database "#{db}/ips"
ips_new = CouchRest.database "#{db}/ips_prod"

# same format
