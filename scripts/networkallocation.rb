require 'ipaddress'

vlans = {"30"=>"6c77b1cc-fb86-1eb6-c37a-b8638fd11eed", 
         "31"=>"78141536-68d1-d12e-c9ea-92fdfbd77c64", 
         "32"=>"6cdd012e-47ae-b985-6e9e-dabd84d45e26",
         "33"=>"dfecf436-5fc4-448e-4716-7aa1490c9639"}

vlan = ARGV[0] or abort "need vlan number"

waab = ARGV[1] or abort "need vmid"

ssh = "ssh -i ~/.ssh/id_vm-query root@172.20.0.8"
vif = `#{ssh} xe vif-list vm-uuid=#{waab}`
vif_adapter = vif.match( /^uuid.*: (.*)$/ )[1] 
puts vif_adapter

powerstate = `#{ssh} xe vm-param-get uuid=#{waab} param-name=power-state`
powerstate.chomp!

if powerstate != "halted"
        abort "need to shutdown"
end

`#{ssh} xe vif-destroy uuid=#{vif_adapter}` 

network_uuid = vlans[vlan]

newadap = `#{ssh} xe vif-create network-uuid=#{network_uuid} vm-uuid=#{waab} device=0`

