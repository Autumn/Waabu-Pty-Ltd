require 'rubygems'
require 'json'
require 'couchrest'

module Waabu

  class VMSpinup
  
    SSH = "ssh #{XEN_SERVER}"

    VM_DB = CouchRest.database("#{DB_SERVER}/#{VM_DB}")

    def self.define_vm params
      vm = {}

      disk_prefix = case params[:storagetype]
      when "hdd"
        "hdd"
      when "ssd"
        "ssd"
      else return {:error => "invaild storage type"}
      end

      supported_os = [
        "centos-5.10-32", "centos-5.10-64",
        "centos-6.5-32", "centos-6.5-64",
        "debian-7.4-32", "debian-7.4-64",
        "ubuntu-12.04-32", "ubuntu-12.04-64",
        "ubuntu-13.10-32", "ubuntu-13.10-64",
        "ubuntu-14.04-32", "ubuntu-14.04-64",
        "arch-2014-32", "arch-2014-64"
      ]

      if supported_os.include? params[:os] 
        vm[:os]= "#{disk_prefix}-#{params[:os]}" 
      else
        return {:error => "invalid os"} 
      end
 
      vm[:ram] = case params[:ram]
      when 512
        "512MiB"
      when 1024
        "1GiB" 
      when 2048
        "2GiB"
      when 4096
        "4GiB"
      when 8192
        "8GiB"
      when 12288
        "12GiB"
      else
        return {:error => "invalid ram"}
      end

       vm[:storage] = case params[:storage]
      when 10
        "10GiB"
      when 20
        "20GiB"
      when 30
        "30GiB"
      when 40
        "40GiB"
      when 50
        "50GiB"
      when 80
        "80GiB"
      when 100
        "100GiB"
      when 120
        "120GiB"
      when 200
        "200GiB"
      when 500
        "500GiB"
      else
        return {:error => "invalid storage"}
      end

      vm[:cpu] = case params[:cpu]
      when 1
        1
      when 2
        2
      when 3
        3
      when 4
        4
      when 6
        6
      when 8
        8
      else
        return {:error => "invalid cpu"}.to_json
      end
    
      return {:error => "invalid name"}.to_json if params[:name] == nil
      vm[:name] = params[:name]

      vm
    end

    def self.install_vm vm
      puts "Installing VM from template..."
      puts "#{vm}"
      vmid = `#{SSH} xe vm-install template=#{vm[:os]} new-name-label=#{vm[:name]}:#{vm[:os]}`
      vmid.chomp!

      abort "os template #{vm[:os]} not found" if not vmid.match /.*-.*-.*-.*-.*/

      puts "Setting memory limits..."
      `#{SSH} xe vm-memory-limits-set uuid=#{vmid} static-min=#{vm[:ram]} static-max=#{vm[:ram]} dynamic-min=#{vm[:ram]} dynamic-max=#{vm[:ram]}`
      puts "Setting CPU limits..."
      `#{SSH} xe vm-param-set uuid=#{vmid} VCPUs-max=#{vm[:cpu]}`
      `#{SSH} xe vm-param-set uuid=#{vmid} VCPUs-at-startup=#{vm[:cpu]}`

      puts "Creating disk..."
      vdi =  `#{SSH} xe vm-disk-list uuid=#{vmid}`
      vdisk_uuid = vdi.split("\n\n\n")[1].split("\n")[1].split(":")[1].strip
    
      if vm[:storage] != "10GiB"
        puts "Resizing disk..."
        `#{SSH} xe vdi-resize uuid=#{vdisk_uuid} disk-size=#{vm[:storage]}`
        `#{SSH} xe vdi-param-set uuid=#{vdisk_uuid} name-label=#{vm[:name]}`
      end

      puts "Enabling high availability..."
      `#{SSH} xe vm-param-set ha-restart-priority=best-effort uuid=#{vmid}`

      puts "Changing description..."
     `#{SSH} xe vm-param-set uuid=#{vmid} name-description=#{vm[:name]}:#{vm[:os]}:#{vmid}`
      puts "Done."

      puts "Done."

      {:id => vmid}
    end

    def self.start_vm vmid
      puts "Powering on..."
      `#{SSH} xe vm-start uuid=#{vmid}`
      puts "Done."
    end

    def self.get_ip vmid
      puts "Querying xe for IPv4 address..."
      ip_base = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=networks`


      # REWRITE TO BE BETTER

      while ip_base.chomp.match(/0\/ip: (.*); 0\/ipv6\/0: (.*)$/) == nil
        ip_base = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=networks`
      end

      ips = ip_base.chomp.match /0\/ip: (.*); 0\/ipv6\/0: (.*)$/

      ipv4 = ips[1]
      ipv6 = ips[2]
      puts "Done."
      {:ipv4 => ipv4, :ipv6 => ipv6}
    end
   
    def self.configure_vm vmid, ip, params, email
      # change password
      
      # check when we can ssh to machine

      `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} echo`
      while $?.exitstatus != 0
        `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} echo`
      end

      password = (0...16).map { (65 + rand(26)).chr }.join
      `scp -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image ~/waabu/scripts/chpw.sh root@#{ip[:ipv4]}:`
      `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} sh chpw.sh #{password}`
      puts "changed password to #{password}"

      # resize file system

      puts "#{params[:sshkey]}"
      if params[:sshkey] != nil
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/sshkey.sh root@#{ip[:ipv4]}:`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} sh sshkey.sh "#{params[:sshkey].chomp}"`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm sshkey.sh`
      end

      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} resize2fs /dev/xvda #{params[:storage]}G`
 
      # preload ssh key
 
      # remove our keyfile
 
      assigned_ip = self.assign_ip vmid
      vlan = assigned_ip[:vlan]
      public_ip = assigned_ip[:ip]
      puts "#{assigned_ip}"

      os = params[:os].split("-")[0]  

      if ["debian", "ubuntu"].include? os
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/ubuntu-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/ubuntu-if-file.sh root@#{ip[:ipv4]}:`
        if_chg = "sh ubuntu-if.sh #{public_ip["v4"]} #{public_ip["v4gw"]} #{public_ip["v4bc"]} #{public_ip["v6"]} #{public_ip["v6gw"]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm ubuntu-if.sh`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm ubuntu-if-file.sh`
      elsif os == "centos"
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-if-file.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-gw.sh root@#{ip[:ipv4]}:`
        if_chg = "sh centos-if.sh #{public_ip["v4"]} #{public_ip["v4gw"]} #{public_ip["v4bc"]} #{public_ip["v6"]} #{public_ip["v6gw"]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm centos-if.sh centos-if-file.sh centos-gw.sh`
      elsif os == "arch"
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/arch-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/arch-if-file.sh root@#{ip[:ipv4]}:`
        if_chg = "sh arch-if.sh #{public_ip["v4"]} #{public_ip["v4gw"]} #{public_ip["v4bc"]} #{public_ip["v6"]} #{public_ip["v6gw"]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm arch-if.sh arch-if-file.sh`
      end

      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm chpw.sh`
      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} mv .ssh/authorized_keys1 .ssh/authorized_keys`

      adapters = {
        "30" => "6c77b1cc-fb86-1eb6-c37a-b8638fd11eed",
        "31" => "78141536-68d1-d12e-c9ea-92fdfbd77c64",
        "32" => "6cdd012e-47ae-b985-6e9e-dabd84d45e26",
        "33" => "dfecf436-5fc4-448e-4716-7aa1490c9639"
      }

       adapter_uuid = adapters[vlan]
       puts "shutting down vm"
       Waabu::VMInspect.shutdown_vm vmid

       private_vif = `#{SSH} xe vif-list vm-uuid=#{vmid}`
       vif_adapter = private_vif.match( /^uuid.*: (.*)$/ )[1]

       puts "destroying old adapter"
       `#{SSH} xe vif-destroy uuid=#{vif_adapter}`
       puts "creating adapter"
       `#{SSH} xe vif-create network-uuid=#{adapters[vlan]} vm-uuid=#{vmid} device=0`
       puts "starting vm"
       Waabu::VMInspect.start_vm vmid

       # send email
       # with password and ip
       `ssh -i ~/.ssh/id_email root@103.228.135.246 sh send-spinup-mail.sh #{email} #{public_ip["v4"]} #{public_ip["v6"]} #{password}`
       {:vlan => vlan, :ipv4 => public_ip["v4"], :ipv6 => public_ip["v6"]}
    end

    def self.assign_ip vmid

 # search vlan 30
 # if full, vlan 31
 # until vlan 33

      ip_found = false
      ip = {}
      vlans = ["30", "31", "32", "33"]
      vlans.each do |vlan|
        ip[:ip] = Waabu::IP::get_ips vlan
        ip[:vlan] = vlan
        ip_found = true if ip[:error] == nil
        break if ip[:error] == nil
      end
      ip
  
      # get used ips from db
      # generate available ips from network
      # store ip as owned
      # create interface file and reboot
   end

    def self.provision_vm params, email
      puts "#{params}"
      vm = self.define_vm params
      puts "#{vm}"
      id = self.install_vm(vm)[:id]
      self.start_vm id
      ip = self.get_ip id
      ips = self.configure_vm id, ip, params, email
      VM_DB.save_doc({:email => email, :vmid => id, :item => params, :vm => vm, :ipv4 => ips[:ipv4], :ipv6 => ips[:ipv6], :vlan=>ips[:vlan]})
    end

  end

 
end
