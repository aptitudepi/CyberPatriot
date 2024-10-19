apt install ufw -y
ufw disable

cp /etc/ufw/before.rules /etc/ufw/before.rules.bak
cp ~/pre-configured-files/before.rules /etc/ufw/before.rules

cp /etc/ufw/after.rules /etc/ufw/after.rules.bak
cp ~/pre-configured-files/after.rules /etc/ufw/after.rules

echo "MAKE SURE TO ALLOW ALL CRIT SERVICES THRU UFW!"
echo "Press y when done or n to quit ..."
read fquestion
if [ $fquestion == "n" ] || [ $fquestion == "N" ]; then
  exit 1
fi
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
ufw reject telnet
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
ufw logging full > /dev/null
ufw allow in on lo > /dev/null
ufw allow out on lo > /dev/null
ufw deny in from 127.0.0.0/8 > /dev/null
ufw deny out from ::1 > /dev/null
ufw enable
clear
echo "ufw configured" >> ~/script.log
rfkill block all
rfkill unblock wifi
