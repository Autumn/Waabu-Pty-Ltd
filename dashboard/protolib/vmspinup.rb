module Waabu
  class VMSpinup
    SSH = "ssh public-xen"

    def self.spinup_vm vmconf
      id = self.install_vm vmconf
      self.start_vm id
      ipv4 = self.get_ip id
      # returns root password to calling method
      password = self.configure_vm id, ipv4, vmconf
      {:id => id, :password => password}
    end

    def self.install_vm vmconf
      Waabu::Log.info "Beginning spinup for vm #{vmconf[:name]}"
      Waabu::Log.info "Installing VM from template #{vmconf[:os]}..."
      vmid = `#{SSH} xe vm-install template=#{vmconf[:os]} new-name-label=#{vmconf[:name]}:#{vmconf[:os]}`
      vmid.chomp!

      abort "os template #{vmconf[:os]} not found" if not vmid.match /.*-.*-.*-.*-.*/

      ram = "#{vmconf[:ram]}MiB"

      Waabu::Log.info "Setting memory limits RAM=#{ram}..."
      `#{SSH} xe vm-memory-limits-set uuid=#{vmid} static-min=#{ram} static-max=#{ram} dynamic-min=#{ram} dynamic-max=#{ram}`
      Waabu::Log.info "Setting CPU limits CPUS=#{vmconf[:cpu]}.."
      `#{SSH} xe vm-param-set uuid=#{vmid} VCPUs-max=#{vmconf[:cpu]}`
      `#{SSH} xe vm-param-set uuid=#{vmid} VCPUs-at-startup=#{vmconf[:cpu]}`

      Waabu::Log.info "Creating disk #{vmconf[:storage]} #{vmconf[:storagetype]}"
      vdi =  `#{SSH} xe vm-disk-list uuid=#{vmid}`
      vdisk_uuid = vdi.split("\n\n\n")[1].split("\n")[1].split(":")[1].strip

      storage = "#{vmconf[:storage]}GiB"
      if storage != "10GiB"
        Waabu::Log.info "Resizing disk..."
        `#{SSH} xe vdi-resize uuid=#{vdisk_uuid} disk-size=#{storage}`
        `#{SSH} xe vdi-param-set uuid=#{vdisk_uuid} name-label=#{vmconf[:name]}`
      end

      Waabu::Log.info "Enabling high availability..."
      `#{SSH} xe vm-param-set ha-restart-priority=best-effort uuid=#{vmid}`

      Waabu::Log.info "Changing description..."
     `#{SSH} xe vm-param-set uuid=#{vmid} name-description=#{vmconf[:name]}:#{vmconf[:os]}:#{vmid}`
      Waabu::Log.info "Completed spinup for #{vmconf[:name]}"

      vmid
    end

    def self.start_vm vmid
      Waabu::Log.info "Powering on vm #{vmid}"
      `#{SSH} xe vm-start uuid=#{vmid}`
      Waabu::Log.info "Powered on vm #{vmid}"
    end

    def self.get_ip vmid
      Waabu::Log.info "Querying vm #{vmid} for IPv4 address..."
      ip_base = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=networks`

      # REWRITE TO BE BETTER

      while ip_base.chomp.match(/0\/ip: (.*); 0\/ipv6\/0: (.*)$/) == nil
        ip_base = `#{SSH} xe vm-param-get uuid=#{vmid} param-name=networks`
      end

      ips = ip_base.chomp.match /0\/ip: (.*); 0\/ipv6\/0: (.*)$/

      ipv4 = ips[1]
      ipv6 = ips[2]
      Waabu::Log.info "IP #{ipv4} found for vm #{vmid}"
      {:ipv4 => ipv4, :ipv6 => ipv6}
    end

    def self.configure_vm vmid, ip, vmconf
      # change password

      # check when we can ssh to machine

      Waabu::Log.info "Beginning config for vm #{vmid} with IP #{ip[:ipv4]}"

      `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} echo`
      while $?.exitstatus != 0
        `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} echo`
      end

      password = (0...16).map { (65 + rand(26)).chr }.join
      `scp -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image ~/waabu/scripts/chpw.sh root@#{ip[:ipv4]}:`
      `ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} sh chpw.sh #{password}`
      Waabu::Log.info "Changed password of vmid #{vmid} to #{password}"

      # resize file system

      if vmconf[:sshkey] != nil
         Waabu::Log.info "Loading ssh key onto vm #{vmid}"
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/sshkey.sh root@#{ip[:ipv4]}:`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} sh sshkey.sh "#{vmconf[:sshkey].chomp}"`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm sshkey.sh`
      end

      Waabu::Log.info "Resizing file system on vm #{vmid} to #{vmconf[:storage]}GB"
      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} resize2fs /dev/xvda #{vmconf[:storage]}G`


      vlan = vmconf[:vlan]

      os = vmconf[:os].split("-")[1]

      Waabu::Log.info "Assigning IP addresses #{vmconf[:ipv4]} #{vmconf[:ipv6]} to vm #{vmid}"

      if ["debian", "ubuntu"].include? os
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/ubuntu-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/ubuntu-if-file.sh root@#{ip[:ipv4]}:`
        if_chg = "sh ubuntu-if.sh #{vmconf[:ipv4]} #{vmconf[:v4gw]} #{vmconf[:v4bc]} #{vmconf[:ipv6]} #{vmconf[:v6gw]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm ubuntu-if.sh`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm ubuntu-if-file.sh`
        Waabu::Log.info "Created interface files for vm #{vmid}"
      elsif os == "centos"
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-if-file.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/centos-gw.sh root@#{ip[:ipv4]}:`
        if_chg = "sh centos-if.sh #{vmconf[:v4]} #{vmconf[:v4gw]} #{vmconf[:v4bc]} #{vmconf[:ipv6]} #{vmconf[:v6gw]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm centos-if.sh centos-if-file.sh centos-gw.sh`
        Waabu::Log.info "Created interface files for vm #{vmid}"
      elsif os == "arch"
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/arch-if.sh root@#{ip[:ipv4]}:`
        `scp -i ~/.ssh/id_spinup-image ~/waabu/scripts/arch-if-file.sh root@#{ip[:ipv4]}:`
        if_chg = "sh arch-if.sh #{vmconf[:v4]} #{vmconf[:v4gw]} #{vmconf[:v4bc]} #{vmconf[:ipv6]} #{vmconf[:v6gw]} 114"
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} #{if_chg}`
        `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm arch-if.sh arch-if-file.sh`
        Waabu::Log.info "Created interface files for vm #{vmid}"
      end

      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm chpw.sh`
      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm .bash_history .bashrc`
      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} rm -rf .profile .cache`
   
      `ssh -i ~/.ssh/id_spinup-image root@#{ip[:ipv4]} mv .ssh/authorized_keys1 .ssh/authorized_keys`

      adapters = {
        "30" => "6c77b1cc-fb86-1eb6-c37a-b8638fd11eed",
        "31" => "78141536-68d1-d12e-c9ea-92fdfbd77c64",
        "32" => "6cdd012e-47ae-b985-6e9e-dabd84d45e26",
        "33" => "dfecf436-5fc4-448e-4716-7aa1490c9639",
        "36" => "80d38873-a8e3-7d27-d873-545b05573ec9"
      }

       adapter_uuid = adapters[vlan]
       puts "#{vlan} #{adapter_uuid}"
       Waabu::Log.info "shutting down vm #{vmid} for adapter change"
       Waabu::VMInspect.shutdown_vm vmid

       private_vif = `#{SSH} xe vif-list vm-uuid=#{vmid}`
       vif_adapter = private_vif.match( /^uuid.*: (.*)$/ )[1]

       Waabu::Log.info "destroying old adapter #{vif_adapter} for vm #{vmid}"
       `#{SSH} xe vif-destroy uuid=#{vif_adapter}`
       Waabu::Log.info "creating adapter on vlan #{vlan} with adapter #{adapters[vlan]} for vm #{vmid}"
       `#{SSH} xe vif-create network-uuid=#{adapters[vlan]} vm-uuid=#{vmid} device=0`

       Waabu::Log.info "starting vm #{vmid}"

       Waabu::VMInspect.start_vm vmid

       # send email
       # with password and ip
       #`ssh -i ~/.ssh/id_email root@103.228.135.246 sh send-spinup-mail.sh #{email} #{public_ip["v4"]} #{public_ip["v6"]} #{password}`
       Waabu::Log.info "configuration for vm #{vmid} complete"

       password
    end
  end
end
