#!/bin/bash
mkdir ubucis
cd ubucis

#postfix
echo "please set inet_interfaces = loopback-only in /etc/postfix/main.cf" > ~/ubucis/postfix.txt

#ufw
apt install -y ufw
apt purge -y iptables-persistent
systemctl unmask ufw.service
systemctl --now enable ufw.service
ufw enable
ufw logging full
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny out from ::1
ufw allow out on all
cp ~/pre-configured-files/before.rules /etc/ufw/before.rules
ufw reload

#disable dccp, sctp, rds, tipc
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf

#avahi server is not on check
systemctl stop avahi-daemon.service &> /dev/null
systemctl stop avahi-daemon.socket &> /dev/null
apt purge -y avahi-daemon &> /dev/null

#cups is not on check
apt purge -y cups

#dhcp server not on check
apt purge -y isc-dhcp-server

#ldap server not on check
apt purge -y slapd &> /dev/null

#nfs not on check
apt purge -y nfs-kernel-server &> /dev/null

#dns server not on check
apt purge -y bind9 &> /dev/null

#imap and pop3 not on check
apt purge -y dovecot-imapd &> /dev/null
apt purge -y dovecot-pop3d &> /dev/null

#snmp not on check
apt purge -y snmpd &> /dev/null

#no nis
apt purge -y nis &> /dev/null

#no rsync
apt purge -y rsync &> /dev/null

#no rsh
apt purge -y rsh-client &> /dev/null
apt purge -y rsh-redone-client &> /dev/null

#no talk
apt purge -y talk &> /dev/null
apt purge -y ntalk &> /dev/null

#no telnet
apt purge -y telnet &> /dev/null

#no ldap client
apt purge -y ldap-utils &> /dev/null

#no rpcbind
apt purge -y rpcbind &> /dev/null

printf "install cramfs /bin/false blacklist cramfs" >> /etc/modprobe.d/cramfs.conf
modprobe -r cramfs

printf "install squashfs /bin/false blacklist squashfs" >> /etc/modprobe.d/squashfs.conf
modprobe -r squashfs
printf "install udf /bin/false blacklist udf " >> /etc/modprobe.d/udf.conf
modprobe -r udf
systemctl unmask tmp.mount
