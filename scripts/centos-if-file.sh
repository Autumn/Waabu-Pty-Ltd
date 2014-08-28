echo DEVICE=eth0
echo NM_CONTROLLED=yes
echo ONBOOT=yes
echo TYPE=Ethernet
echo BOOTPROTO=static
echo IPADDR=$1
echo GATEWAY=$2
echo BROADCAST=$3
echo NETMASK=255.255.255.0

echo IPV6INIT=yes
echo IPV6ADDR=$4/$6
echo IPV6_DEFAULTGW=$5
