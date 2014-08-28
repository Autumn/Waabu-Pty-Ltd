module Waabu
  class IP

    DB = CouchRest.database! "#{Waabu::DB_SERVER}/#{Waabu::IP_DB}"

    def self.bootstrap_db
      search = {
        "ipv4" => {"map"=>"function(doc){if(doc.ipv4){emit(doc.ipv4,doc);}}"},
        "ipv6" => {"map"=>"function(doc){if(doc.ipv6){emit(doc.ipv6,doc);}}"},
        "vlan" => {"map"=>"function(doc){if(doc.vlan){emit(doc.vlan,doc);}}"}
      }

      view = {"_id"=>"_design/search", "views"=>search}

      DB.save_doc view
    end

    def self.clean_db
      DB.get("_all_docs")["rows"].each do |row|
        DB.delete_doc({"_id"=>row["id"], "_rev"=>row["value"]["rev"]})
      end
    end

     IPV6_RANGE = {
      "30" => IPAddress::IPv6.new("2400:d080:8000::/114"),
      "31" => IPAddress::IPv6.new("2400:d080:8000::800/114"),
      "32" => IPAddress::IPv6.new("2400:d080:8000::1000:0/114"),
      "33" => IPAddress::IPv6.new("2400:d080:8000::1800:0/114")
    }

    def self.get_usable_ipv6s network
      usable_ips = []
      netaddr = IPAddress::IPv6.compress network.address
      gateway = IPAddress::IPv6.compress network.address.next
      all_hosts = network.to_a.map{|x|x.to_s}
      usable = all_hosts - [gateway, netaddr]
      usable.each do |ip| usable_ips.push({:host=>ip, :gateway=>gateway, :network=>network}) end
      usable_ips
    end

    IPV6_USABLE = {
      "30" => self.get_usable_ipv6s(IPV6_RANGE["30"]),
      "31" => self.get_usable_ipv6s(IPV6_RANGE["31"]),
      "32" => self.get_usable_ipv6s(IPV6_RANGE["32"]),
      "33" => self.get_usable_ipv6s(IPV6_RANGE["33"])
    }

    def self.get_ips vlan
      # get ips

      # register as used

      assigned_ipv4 = false
      assigned_ipv6 = false

      # need vlan, ipv4, ipv4 gateway, ipv4 broadcast, ipv6, ipv6 gateway
      ip = {}

      while not assigned_ipv4
        begin
          # get ipv4
          ipv4 = get_ipv4 vlan
          return {:error => "no ipv4s left in vlan #{vlan}"} if ipv4[:error] != nil
          doc = {"_id" => ipv4[:host], "vlan"=>vlan, "ipv4"=> ipv4[:host]}
          DB.save_doc doc
          ip = {"vlan" => vlan, "v4" => ipv4[:host], "v4gw" => ipv4[:gateway], "v4bc" => ipv4[:broadcast]}
          # get ipv6
          # try to save ip
          assigned_ipv4 = true
        rescue RestClient::Conflict
          # try again
          assigned_ipv4 = false
        end
      end
      while not assigned_ipv6
        begin
          # get ipv4
          ipv6 = get_ipv6 vlan
          return {:error => "no ipv6s left in vlan #{vlan}"} if ipv4[:error] != nil
          doc = {"_id" => ipv6[:host], "vlan"=>vlan, "ipv6" => ipv6[:host]}
          DB.save_doc doc
          ip["v6"] = ipv6[:host]
          ip["v6gw"] = ipv6[:gateway]
          assigned_ipv6 = true
        rescue RestClient::Conflict
          # try again
          assigned_ipv6 = false
        end
      end

      return ip
    end

    def self.get_ipv4 vlan
      # get unused ipv4 and mark it as used
      ips = {"30" => IPAddress::IPv4.new("103.228.132.0/24"),
             "31" => IPAddress::IPv4.new("103.228.133.0/24"),
             "32" => IPAddress::IPv4.new("103.228.134.0/24"),
             "33" => IPAddress::IPv4.new("103.228.135.0/25")
            }

      used_ipv4 = DB.view("search/ipv4")["rows"]
      used_ips = {}
      used_ipv4.each do |ip|
        if ip["value"]["vlan"] == vlan
          used_ips[ip["id"]] = ip["value"]
        end
      end

      usable_ips = self.get_usable_ipv4s ips[vlan]

      usable_ips.each do |ip|
        if used_ips[ip[:host]] == nil
          # done
          return ip
        end
      end
      {:error => "no ip found in vlan"}

    end

    def self.get_ipv6 vlan
      # get unused ipv6 and mark it as used

      used_ipv6 = DB.view("search/ipv6")["rows"]
      used_ips = {}
      used_ipv6.each do |ip|
        if ip["value"]["vlan"] == vlan
          used_ips[ip["id"]] = ip["value"]
        end
      end

      IPV6_USABLE[vlan].each do |ip|
        if used_ips[ip[:host]] == nil
          # done
          return ip
        end
      end
      {:error => "no ip found in vlan"}

    end

    def self.get_usable_ipv4s network
      usable_ips = []
      gateway = network.first.to_s
      netaddr = network.network.to_s
      broadcast = network.broadcast.to_s
      all_hosts = network.to_a.map{|x|x.to_s}
      usable = all_hosts - [gateway, broadcast, netaddr]
      usable.each do |ip| usable_ips.push({:host=>ip, :gateway=>gateway, :network=>network, :broadcast=>broadcast}) end
      usable_ips
    end
  end
end
