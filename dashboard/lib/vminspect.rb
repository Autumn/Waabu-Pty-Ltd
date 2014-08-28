require 'rubygems'
require 'json'

module Waabu

  class VMInspect
    SSH = "ssh #{XEN_SERVER}"
 
    VMDB = CouchRest.database! "#{Waabu::DB_SERVER}/#{Waabu::VM_DB}"
 
    def self.get_vms email
      vms = []
      VMDB.view("search/user")['rows'].each do |row|
        if row["key"] == email
          puts row["value"]
          vms.push({:id => row["value"]["vmconf"]["vmid"], :name=> row["value"]["name"].split(":")[1]})
        end
      end
      {:vms => vms}  
    end

    def self.cpu_usage vmid
      str = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=VCPUs-utilisation`
      res = []
      cpus = str.chomp.split "; "
      cpus.each do |cpu|
        id, load = cpu.split ": "
        res.push({:id => id, :load => load})
      end
      res
    end

    def self.ram_usage vmid
      free_memory = `#{SSH} xe vm-data-source-query data-source=memory_internal_free uuid=#{vmid}`
      total_memory = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=memory-actual`

      free_memory = free_memory.to_i
  
      total_memory = total_memory.to_i

    #Convert kilobytes to Megabytes
      convertfromkilobytes = 1024
      convertfrombytes =  1024 ** 2

      output_free = (free_memory/convertfromkilobytes.to_f).ceil
      output_total = (total_memory/convertfrombytes.to_f).ceil
  
      {:total => output_total, :free => output_free}
    end

    def self.get_ip vmid
      ip_base = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=networks`
      
      ips = ip_base.chomp.match /0\/ip: (.*); 0\/ipv6\/0: (.*)$/
      if ips != nil
        ipv4 = ips[1]
        ipv6 = ips[2]
        {:ipv4 => ipv4, :ipv6 => ipv6}
      else
        {:error => "no ip"}
      end
    end

    def self.os_details vmid
      # not robust
      # replace with db lookup
      os_version = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=os-version`
      res = {}
      ["kernel", "distro", "major", "minor"].zip(os_version.chomp.split("; ")[1..4]).each do |pairs|
        key = pairs[0]
        val = pairs[1].split(": ")[1]
        res[key] = val
      end
      res
    end

    def self.power_state vmid
      power_state = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=power-state`
      {:state => power_state.chomp!}
    end

    def self.storage vmid
      vdi =  `#{SSH} xe vm-disk-list uuid=#{vmid}`
      vdisk_uuid = vdi.split("\n\n\n")[1].split("\n")[1].split(":")[1].strip

      totaldisksize =  `#{SSH} xe vdi-param-get uuid=#{vdisk_uuid} param-name=virtual-size`

      disksize = totaldisksize.to_i

      convertfromkilobytes = 1024
      convertfrombytes =  1024 ** 2

      output_total = (disksize/convertfrombytes.to_f).ceil
      {:total => output_total / 1024}

    end

    def self.reboot_vm vmid
      `#{SSH} xe vm-reboot uuid=#{vmid}`
    end

    def self.shutdown_vm vmid
      `#{SSH} xe vm-shutdown uuid=#{vmid}`
    end

    def self.start_vm vmid
      `#{SSH} xe vm-start uuid=#{vmid}`
    end
  end

end
