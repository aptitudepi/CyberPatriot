#!/bin/bash

#networking and firewall
sudo apt install ufw gufw -y
gufw
sudo apt install iptables -y
apt autoremove --purge -y iptables-persistent
iptables-restore < /etc/iptables/empty.rules
iptables -N TCP
iptables -N UDP
iptables -F
echo """
*filter
:INPUT DROP [15:2711]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [69:6405]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
""" > ~/rulez.txt
iptables-restore ~/rulez.txt
rm rulez.txt
mkdir /iptables/
touch /iptables/rules.v4.bak
touch /iptables/rules.v6.bak
#clear default settings
iptables -t nat -F
iptables -t mangle -F
iptables -t nat -X
iptables -t mangle -X
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -t nat -X
ip6tables -t mangle -X
ip6tables -F
ip6tables -X
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP
iptables -A INPUT -s 127.0.0.0/8 -i $interface -j DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP
iptables -A INPUT -s 100.64.0.0/10 -j DROP
iptables -A INPUT -s 169.254.0.0/16 -j DROP
iptables -A INPUT -s 192.0.0.0/24 -j DROP
iptables -A INPUT -s 192.0.2.0/24 -j DROP
iptables -A INPUT -s 198.18.0.0/15 -j DROP
iptables -A INPUT -s 198.51.100.0/24 -j DROP
iptables -A INPUT -s 203.0.113.0/24 -j DROP
iptables -A INPUT -s 224.0.0.0/3 -j DROP
iptables -A OUTPUT -s 127.0.0.0/8 -o $interface -j DROP
iptables -A OUTPUT -s 0.0.0.0/8 -j DROP
iptables -A OUTPUT -s 100.64.0.0/10 -j DROP
iptables -A OUTPUT -s 169.254.0.0/16 -j DROP
iptables -A OUTPUT -s 192.0.0.0/24 -j DROP
iptables -A OUTPUT -s 192.0.2.0/24 -j DROP
iptables -A OUTPUT -s 198.18.0.0/15 -j DROP
iptables -A OUTPUT -s 198.51.100.0/24 -j DROP
iptables -A OUTPUT -s 203.0.113.0/24 -j DROP
iptables -A OUTPUT -s 224.0.0.0/3 -j DROP
iptables -A INPUT -d 127.0.0.0/8 -i $interface -j DROP
iptables -A INPUT -d 0.0.0.0/8 -j DROP
iptables -A INPUT -d 100.64.0.0/10 -j DROP
iptables -A INPUT -d 169.254.0.0/16 -j DROP
iptables -A INPUT -d 192.0.0.0/24 -j DROP
iptables -A INPUT -d 192.0.2.0/24 -j DROP
iptables -A INPUT -d 198.18.0.0/15 -j DROP
iptables -A INPUT -d 198.51.100.0/24 -j DROP
iptables -A INPUT -d 203.0.113.0/24 -j DROP
iptables -A INPUT -d 224.0.0.0/3 -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -d 127.0.0.0/8 -o $interface -j DROP
iptables -A OUTPUT -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -d 224.0.0.0/3 -j DROP
iptables -A INPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -P OUTPUT DROP
mkdir /etc/iptables/
touch /etc/iptables/rules.v4
touch /etc/iptables/rules.v6
iptables-save >> /etc/iptables/rules.v4
ip6tables-save >> /etc/iptables/rules.v6
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP #Telnet blocked
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 23 -j DROP
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP #NFS blocked (hash out if you need file sharing)
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP #X-Windows blocked
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP #X-Windows font server blocked
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 7100 -j DROP
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP #printer port blocked
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        
sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP #Sun rpc/NFS blocked
sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP
#sudo iptables -A INPUT -p all -s localhost  -i eth0 -j DROP #Deny outside packets from internet
iptables -I INPUT -p tcp --dport ssh -i eth0 -m state --state NEW -m recent  --set
iptables -I INPUT -p tcp --dport ssh -i eth0 -m state --state NEW -m recent  --update --seconds 15 --hitcount 3 -j DROP
iptables -A INPUT ! -i eth0 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --tcp-flags ACK ACK -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state RELATED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 1024:65535 --sport 53 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type source-quench -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type parameter-problem -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A INPUT -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A OUTPUT -p icmp -o eth0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -s 0/0 -i eth0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -s 0/0 -i eth0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -s 0/0 -i eth0 -j ACCEPT
iptables -A INPUT -p icmp -i eth0 -j DROP
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable
iptables -A INPUT -p tcp --dport ssh -j ACCEPT
iptables -A TCP -p tcp --dport 80 -j ACCEPT
iptables -A TCP -p tcp --dport 443 -j ACCEPT
iptables -A TCP -p tcp --dport 53 -j ACCEPT
iptables -A UDP -p udp --dport 53 -j ACCEPT
iptables -I TCP -p tcp -m recent --update --rsource --seconds 60 --name TCP-PORTSCAN -j REJECT --reject-with tcp-reset
iptables -D INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp -m recent --set --rsource --name TCP-PORTSCAN -j REJECT --reject-with tcp-reset
iptables -I UDP -p udp -m recent --update --rsource --seconds 60 --name UDP-PORTSCAN -j REJECT --reject-with icmp-port-unreachable
iptables -D INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p udp -m recent --set --rsource --name UDP-PORTSCAN -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable
iptables -N fw-interfaces
iptables -N fw-open
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -j fw-interfaces 
iptables -A FORWARD -j fw-open 
iptables -A FORWARD -j REJECT --reject-with icmp-host-unreachable
iptables -P FORWARD DROP
sed -i 's/IPV6=.*/IPV6=no/' /etc/default/ufw
sed -i 's/IPT_SYSCTL=.*/IPT_SYSCTL=\/etc\/sysctl\.conf/' /etc/default/ufw
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny from any to 224.0.0.1
#ufw allow log from $ADMINNETWORK to any port 22 proto tcp
ufw default deny incoming
ufw --force enable
iptables-save
sudo ufw enable
systemctl start ufw
ufw reject incoming
ufw allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw logging high
sudo ufw deny 23
sudo ufw allow 22000
ufw limit OpenSSH
sudo ufw allow ssh
sudo ufw deny 2049
sudo ufw deny 515
sudo ufw deny 111
ufw allow 80 
ufw reject telnet
ufw allow out 22
ufw allow 21
ufw allow 3307
ufw allow 53
ufw deny 23
ufw allow 137
ufw allow 138
ufw allow 139
ufw allow 445
ufw deny 1080
ufw deny 5554
ufw deny 2745
ufw deny 3127
ufw deny 4444
ufw deny 8866
ufw deny 9898
ufw deny 9988
ufw deny 12345
ufw deny 27374
ufw deny 31337
ufw allow 8200
ufw allow http
ufw allow https
sudo ufw deny rtelent && sudo ufw deny telnet && sudo ufw deny telnetd
sudo ufw deny netcat
sudo lsof  -i -n -P
iptables-save >> /root/my.active.firewall.rules
iptables-save >> /iptables/rules.v4.bak
ip6tables-save >> /iptables/rules.v6.bak
systemctl unmask ufw.service > /dev/null
systemctl --now enable ufw.service > /dev/null
ufw enable > /dev/null
ufw logging full > /dev/null
ufw allow in on lo > /dev/null
ufw allow out on lo > /dev/null
ufw deny in from 127.0.0.0/8 > /dev/null
ufw deny out from ::1 > /dev/null
clear
echo "iptables configured" >> ~/script.log
rfkill block all
rfkill unblock wifi

