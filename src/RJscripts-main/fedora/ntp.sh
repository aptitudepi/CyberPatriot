#!/bin/bash
sudo dnf install chrony
sudo dnf install ntp
#start the service
systemctl start chronyd
ip addr
ifconfig
echo "enter the ip addr of the local system (with cidr)"
read iplocal
echo "allow $iplocal" >> /etc/chrony.conf
systemctl restart chronyd
echo "restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap" >> /etc/ntp.conf
echo "restrict 127.0.0.1" >> /etc/ntp.conf
driftfile /var/lib/ntp/ntp.drift
logfile /var/log/ntp.log
service ntpd start
/etc/init.d/ntp start
echo "now enter the ip addr of local system without cidr"
read ip1
ipconfig
ip addr
server $ip1 prefer
ntpdate –u $ip1
