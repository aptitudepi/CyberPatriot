#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

touch /var/log/script.log

# backups
mkdir -p ~/Desktop/backups/
chmod 700 ~/Desktop/backups/

cp /etc/passwd ~/Desktop/backups
cp /etc/group ~/Desktop/backups
echo "Backups made"

echo "BEGIN FILES.SH"


apt --purge autoremove telnet* iodine* kismet* nikto* john* medusa* hydra* fcrackzip* empathy* tcpdump* vino* tightvncserver* rdesktop* remmina* vinagre* netcat* aircrack* goldeneye* fakeroot* nmap* fcrackzip* postgresql* mariadb* mongodb* postfix* 
if [ dpkg -l | grep "nginx" ]; then
    echo "remove nginx?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge nginx*
    fi
fi

if [ dpkg -l | grep "apache2" ]; then
    echo "remove apache2?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge apache2*

    fi
fi

if [ dpkg -l | grep "mysql" ]; then
    echo "remove mysql?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge mysql*
    fi
fi

if [ dpkg -l | grep "vsftpd" ]; then
    echo "remove vsftpd?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge vsftpd*
    fi
fi

if [ dpkg -l | grep "samba" ]; then
    echo "remove samba?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge samba*
    fi
fi

if [ dpkg -l | grep "openssh-server" ]; then
    echo "remove ssh?"
    read yn
    if [ "$yn" = "y" ];then
        apt autoremove -y --purge openssh-server
    fi
fi


apt install locate -y
updatedb
locate *.jpg *.gif *.bmp *.wav *.mp3 *.ogg *.acc *.mp4 *.mov *.hevc | grep -v "/usr"
locate "password" "card" "credit" "debit" "pin" "cvv" "cvv2" "cvv3" "cvv4" "cvv5" "cvv6" "cvv7" "cvv8" "cvv9" "cvv10" "cvv11" "cvv12" "cvv13" "cvv14" "cvv15" "cvv16" "cvv17" "cvv18" "cvv19" "cvv20" "cvv21" "cvv22" "cvv23" "cvv24" "cvv25" "cvv26" "cvv27" "cvv28" "cvv29" "cvv30" "cvv31" "cvv32" "cvv33" "cvv34" "cvv35" "cvv36" "cvv37" "cvv38" "cvv39" "cvv40" "cvv41" "cvv42" "cvv43" "cvv44" "cvv45" "cvv46" "cvv47" "cvv48" "cvv49" "cvv50" "cvv51" "cvv52" "cvv53" "cvv54" "cvv55" "cvv56" "cvv57" "cvv58" "cvv59" "cvv60" "cvv61" "cvv62" "cvv63" "cvv64" "cvv65" "cvv66" "cvv67" "cvv68" "cvv69" "cvv70" "cvv71" "cvv72" "cvv73" "cvv74" "cvv75" "cvv76" "cvv77" "cvv78" "cvv79" "cvv80" "cvv81" "cvv82" "cvv83" "cvv84" "cvv85" "cvv86" "cvv87" "cvv88" "cvv89" "cvv90" "cvv91" "cvv92" "cvv93" "cvv94" "cvv95" "cvv96" "cvv97" "cvv98" "cv"

echo "Searching for SUID files?\n"
read me
find / -perm /4000

echo "Searching for SGID files?\n"
read me
find / -perm /2000

echo "Secure file permissions?\n"
read me
chmod 644 /etc/*
chmod 600 /etc/shadow
chmod 644 /var/log/*

#Passwords
cp login.defs /etc/login.defs
echo "----Installing libpam-cracklib-----"
apt install libpam-cracklib
echo "Copy common-password into /etc/pam.d/common-password?"
read me
cp common-password /etc/pam.d/common-password
echo "Copy common-auth?"
read me
cp common-auth /etc/pam.d/common-auth
if [[ $(grep "Defaults !authenticate" /etc/sudoers) || $(grep "Defaults !authenticate" /etc/sudoers.d/*) ]]; then
    echo "----Defaults !authenticate has been found in sudoers. Removing it----"
    sed -i '/Defaults !authenticate/d' /etc/sudoers
    sed -i '/Defaults !authenticate/d' /etc/sudoers.d/*
fi

#Backdoors

#networking
echo "doing crontabs..."
read me
echo -e "\n"
echo -e "\n"
echo -e "\n"

echo "----BEGIN /ETC/CRONTAB----"
cat /etc/crontab
echo "----END /ETC/CRONTAB----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/CRON.D----"
cat /etc/cron.d/*
echo "----END /ETC/CRON.D----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /VAR/SPOOL/CRON/CRONTABS----"
cat /var/spool/cron/crontabs/*
echo "----END /VAR/SPOOL/CRON/CRONTABS----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
if [[ $(cat /etc/crontab /etc/cron.d/* /var/spool/cron/crontabs/* | grep -v "* * * * *") ]]; then
    echo "Cronjobs found. Check them out"
fi

echo "doing firewall and iptables..."
read me
apt install iptables
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP #Blocking Telnet
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 23 -j DROP
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP #Blocking NFS
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP #Blocking X-Windows
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP #Block X-Windows font server
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 7100 -j DROP
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP #Block printer port
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        
iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP #Block Sun rpc/NFS
iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP
iptables -A INPUT -p all -s localhost  -i eth0 -j DROP #Deny outside packets from internet
ufw enable
ufw deny 23
ufw deny 2049
ufw deny 515
ufw deny 111
ufw deny rtelent && sudo ufw deny telnet && sudo ufw deny telnets
ufw deny netcat
lsof  -i -n -P

#sysctl.conf
echo -e "\n"
echo "doing /etc/sysctl.conf..."
read me
cp /etc/sysctl.conf sysctl.conf.bak
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/SYSCTL.CONF----"
cat /etc/sysctl.conf

echo "----END /ETC/SYSCTL.CONF----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
read me
wget https://klaver.it/linux/sysctl.conf -P /etc/sysctl.conf
sysctl -ep

#resolv.conf
echo -e "\n"
echo "doing /etc/resolv.conf..."
read me
cp /etc/resolv.conf resolv.conf.bak
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/RESOLV.CONF----"
cat /etc/resolv.conf
echo "----END /ETC/RESOLV.CONF----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
read me
cp resolv.conf /etc/resolv.conf

#host.conf
echo -e "\n"
echo "doing /etc/host.conf..."
read me
cp /etc/host.conf host.conf.bak
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/HOST.CONF----"
cat /etc/hosts
echo "----END /ETC/HOST.CONF----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
read me
cp host.conf /etc/host.conf

#users
#TODO: ADD/REMOVE USERs

# adduser.conf
echo -e "\n"
echo "doing /etc/adduser.conf..."
read me
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/ADDUSER.CONF----"
cat /etc/adduser.conf
echo "----END /ETC/ADDUSER.CONF----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
read me
cp adduser /etc/adduser.conf

#deluser.conf
echo -e "\n"
echo "doing /etc/deluser.conf..."
read me
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN /ETC/DELUSER.CONF----"
cat /etc/deluser.conf
echo "----END /ETC/DELUSER.CONF----"
echo -e "\n"
echo -e "\n"
echo -e "\n"
read me
cp adduser /etc/deluser.conf

passwd -l root

echo "Configuring gdm3..."
read me
cp gdm3 /etc/gdm3/custom.conf
service gdm3 restart

echo -e "\n"
echo -e "\n"
echo -e "\n"
echo "----BEGIN SERVICES----"


echo "-----SHOULD I CONFIGURE SSH?-----"
read me
if [[ $me == "y" ]]; then
    echo "doing ssh..."
    read me
    apt install openssh-server
    cp /etc/ssh/sshd_config sshd_config.bak
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo "----BEGIN /ETC/SSH/SSHD_CONFIG----"
    cat /etc/ssh/sshd_config
    echo "----END /ETC/SSH/SSHD_CONFIG----"
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    read me
    cp betterssh /etc/ssh/sshd_config
    
    service ssh restart
fi


echo "-----SHOULD I CONFIGURE VSFTPD?-----"
read me
if [[ $me == "y" ]]; then
    echo "doing vsftpd..."
    read me
    apt install vsftpd
    cp /etc/vsftpd.conf vsftpd.conf.bak
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo "----BEGIN /ETC/VSFTPD.CONF----"
    cat /etc/vsftpd.conf
    echo "----END /ETC/VSFTPD.CONF----"
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    read me
    cp vsftpd /etc/vsftpd.conf
    service vsftpd restart
fi

echo "-----SHOULD I CONFIGURE PRO-FTPD?-----"
read me
if [[ $me == "y" ]]; then
    echo "doing proftpd..."
    read me
    apt install proftpd
    cp /etc/proftpd/proftpd.conf proftpd.conf.bak
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo "----BEGIN /ETC/PROFTPD/PROFTPD.CONF----"
    cat /etc/proftpd/proftpd.conf
    echo "----END /ETC/PROFTPD/PROFTPD.CONF----"
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    read me
    cp proftpd /etc/proftpd/proftpd.conf
    service proftpd restart
fi

echo "-----SHOULD I CONFIGURE PUREFTPD?-----"
read me
if [[ $me == "y" ]]; then
    echo "doing pureftpd..."
    read me
    apt install pure-ftpd
    cp /etc/pure-ftpd/pure-ftpd.conf pure-ftpd.conf.bak
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo "----BEGIN /ETC/PURE-FTPD/PURE-FTPD.CONF----"
    cat /etc/pure-ftpd/pure-ftpd.conf
    echo "----END /ETC/PURE-FTPD/PURE-FTPD.CONF----"
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    read me
    cp pure-ftpd /etc/pure-ftpd/pure-ftpd.conf
    service pure-ftpd restart
fi

echo "-----SHOULD I CONFIGURE OPENVPN?-----"
read me
if [[ $me == "y" ]]; then
    echo "doing openvpn..."
    read me
    apt install openvpn
    cp /etc/openvpn/server.conf server.conf.bak
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo "----BEGIN /ETC/OPENVPN/SERVER.CONF----"
    cat /etc/openvpn/server.conf
    echo "----END /ETC/OPENVPN/SERVER.CONF----"
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    read me
    cp openvpn.conf /etc/openvpn/server.conf
    service openvpn restart
    openvpn --genkey --secret ta.key
fi


#SERVICES TODO: SAMBA, LAMP

echo "upgrading..."
read me
#bash upgrade
apt install --only-upgrade bash
#kernel upgrade
apt-get dist-upgrade
#remove unnecessary dependencies
apt autoremove
#remove unsupported pkgs
apt autoclean
echo "do unattended upgrades?"
read yn
#unattended upgrades
apt install unattended-upgrades -y
dpkg-reconfigure --priority=low -plow unattended-upgrades
cp auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
