echo auto lo
echo iface lo inet loopback
echo
echo auto eth0
echo iface eth0 inet static
echo address $1
echo netmask 255.255.255.0
echo gateway $2
echo broadcast $3
echo
echo iface eth0 inet6 static
echo pre-up modprobe ipv6
echo address $4
echo gateway $5
echo netmask $6

