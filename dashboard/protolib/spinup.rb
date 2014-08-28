require 'couchrest'

module Waabu
  class Spinup
    VMDB = CouchRest.database! "http://172.24.0.7:5984/devel_vms"

    def self.bootstrap_db
      # create views
      search = {
        "name" => {"map"=>"function(doc){if(doc.name){emit(doc.name,doc);}}"},
        "user" => {"map"=>"function(doc){if(doc.user){emit(doc.user,doc);}}"},
        "subscriptionid" => {"map"=>"function(doc){if(doc.subscriptionid){emit(doc.subscriptionid,doc);}}"},
        "vlan" => {"map"=>"function(doc){if(doc.vlan){emit(doc.vlan,doc);}}"},
        "ipv4" => {"map"=>"function(doc){if(doc.ipv4){emit(doc.ipv4,doc);}}"},
        "ipv6" => {"map"=>"function(doc){if(doc.ipv6){emit(doc.ipv6,doc);}}"}
      }

      view = {"_id"=>"_design/search", "views"=>search}

      VMDB.save_doc view
    end

    def self.clean_db
      VMDB.get("_all_docs")["rows"].each do |row|
        VMDB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

    def self.spinup user, subscriptionid, item
      product = Waabu::Cart.search_product item["id"]
      if product["type"] == "waab"
        Waabu::Log.info "Spinning up #{product["type"]} for subscription #{subscriptionid} for #{user}"
        self.spinup_vm user, item, subscriptionid
      end
    end

    def self.spinup_vm user, item, subscriptionid
      # MUST MAKE SURE ITEM IS VALID BEFORE CALLING

      vmconf = self.get_vmconf user, item
      # gets vm id and password from spinup
      results = Waabu::VMSpinup.spinup_vm vmconf
      vmconf[:vmid] = results[:id]
      vmconf[:password] = results[:password]
      self.save_vmconf user, subscriptionid, vmconf
      Waabu::Log.info "Sending spinup complete email to user #{user} for vm #{vmconf[:vmid]} #{vmconf[:name]}"
      Waabu::Email.vmspinup_complete user, vmconf[:ipv4], vmconf[:ipv6], vmconf[:password]
    end

    def self.assign_ip 
      Waabu::IP.get_ips "33"
    end

    def self.get_vmconf user, item
      vm = {}
      product = Waabu::Cart.search_product item["id"]
      vm[:sshkey] = item["options"]["sshkey"]
      vm[:cpu] = product["config"]["cpu"]
      vm[:ram] = product["config"]["ram"] 
      vm[:storage] = product["config"]["storage"]
      vm[:storagetype] = product["config"]["storagetype"]
      vm[:os] = "#{vm[:storagetype]}-#{item["options"]["os"]}"

      item["options"]["upgrades"].each_key do |upgrade|
        if item["options"]["upgrades"][upgrade]["enabled"]
	  if upgrade == "hdd"
	    vm[:storage] = product["config"]["upgrades"][upgrade]["quantity"]
	    vm[:storagetype] = upgrade
	  elsif upgrade == "ram"
	    vm[:ram] += product["config"]["upgrades"][upgrade]["quantity"]
	  elsif upgrade == "cpu"
	    vm[:cpu] += product["config"]["upgrades"][upgrade]["quantity"]
	  end
        end
      end

      vm[:name] = "#{user}:#{product["name"]}:#{SecureRandom.uuid}"

      ips = self.assign_ip
      Waabu::Log.info "Assigning IPs #{ips} to #{user}"
      vm[:vlan] = ips["vlan"]
      vm[:ipv4] = ips["v4"]
      vm[:v4gw] = ips["v4gw"]
      vm[:v4bc] = ips["v4bc"]
      vm[:ipv6] = ips["v6"]
      vm[:v6gw] = ips["v6gw"]

      vm
    end

    def self.save_vmconf user, subscriptionid, vmconf
      vm = {}
      vm[:name] = vmconf[:name]
      vm[:subscriptionid] = subscriptionid
      vm[:user] = user
      vm[:vmconf] = vmconf
      Waabu::Log.info "Saving VM #{vm[:name]} for #{user} subscription #{subscriptionid}"
      VMDB.save_doc vm
    end
  end
end
