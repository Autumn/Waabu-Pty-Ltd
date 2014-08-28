sh arch-if-file.sh $1 $2 $3 $4 $5 $6 > /etc/netctl/eth0conf
netctl enable eth0conf
yes | pacman -Rs dhcpcd
