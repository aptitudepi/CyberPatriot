#!/bin/bash
chmod +x logo
sudo ./logo

echo "Did you do your forensics and is the full directory in root's home? y/n"
read fquestion
if [ $fquestion == "n" ] || [ $fquestion == "N" ]; then
  exit 1
fi
#creates backup directory to store backup files
cd ~
#mv ~/2021-CyberPatriot-Scripts-Linux-New/* .
sudo mkdir ~/Desktop
cd Desktop
mkdir backups
cd ~
sudo chmod 777 ~/Desktop/backups/
sudo touch ~/script.log
echo "Backup dir initialized and log file created." >> ~/script.log

#backs up info about groups and users in case anything goes wrong with the script
sudo cp /etc/group ~/Desktop/backups/
sudo cp /etc/passwd ~/Desktop/backups/
sudo cp /etc/lightdm/lightdm.conf ~/Desktop/backups/
sudo cp /etc/hosts ~/Desktop/backups/
sudo cp /etc/ssh/sshd_config ~/Desktop/backups/
sudo cp /etc/pam.d/* ~/Desktop/backups/
sudo cp /etc/apt/* ~/Desktop/backups/

echo "Backups created for group, passwd, lightdm.conf, ssh, pam, and hosts." >> ~/script.log

clear

#Root secured
#passwd -l root
#sudo usermod -p '!' root
#echo "root secured" >> ~/script.log
sudo chmod 644 /etc/passwd
#ssh configs
echo "Would you like to install openssh? y/n"
read opensshyn
if [ $opensshyn == "y" ] || [ $opensshyn == "Y" ]; then
  sudo apt-get install openssh-server -y
  chattr -R -i /etc/ssh/*
  mv ~/pre-configured-files/sshd_config /etc/ssh/sshd_config
  mv ~/pre-configured-files/sshd /etc/pam.d/sshd
  chown root:root /etc/ssh/sshd_config
  sed -i "/PermitUserEnvironment.*no/s/^#//g" /etc/ssh/sshd_config
  echo "Ciphers aes256-ctr" >> /etc/ssh/sshd_config
  echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
  sed -i 's/#Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/' /etc/ssh/sshd_config
  sed -i 's/#Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com/Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com/'
  sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 300/g" /etc/ssh/sshd_config
  sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 0/g" /etc/ssh/sshd_config
  sed -i "s/ClientAliveInterval 0/ClientAliveInterval 300/g" /etc/ssh/sshd_config
  sed -i "s/ClientAliveCountMax 3/ClientAliveCountMax 0/g" /etc/ssh/sshd_config
  sed -i "s/#Banner none/Banner \/etc\/issue\.net/g" /etc/ssh/sshd_config
  CONFIG_SSHD='/etc/ssh/sshd_config'
  groupadd -r sshd_users
  usermod -G sshd_users -a root
  usermod -G sshd_users -a $USER
  sed -i -e 's/^Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/' "$CONFIG_SSHD"
  sed -i -e 's/.*RekeyLimit.*/RekeyLimit 512M 1h/' "$CONFIG_SSHD"
  sed -i -e 's/#LogLevel.*/LogLevel VERBOSE/' "$CONFIG_SSHD"
  sed -i -e 's/#LoginGraceTime.*/LoginGraceTime 30s/' "$CONFIG_SSHD"
  sed -i -e 's/#PermitRootLogin.*/PermitRootLogin no/' "$CONFIG_SSHD"
  sed -i -e 's/#StrictModes.*/StrictModes yes/' "$CONFIG_SSHD"
  sed -i -e 's/#MaxAuthTries.*/MaxAuthTries 3/' "$CONFIG_SSHD"
  sed -i -e 's/#MaxSessions.*/MaxSessions 3/' "$CONFIG_SSHD"
  sed -i -e 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' "$CONFIG_SSHD"
  sed -i -e 's/#AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/' "$CONFIG_SSHD"
  sed -i -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' "$CONFIG_SSHD"
  sed -i -e 's/#PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$CONFIG_SSHD"
  sed -i -e 's/#AllowAgentForwarding.*/AllowAgentForwarding no/' "$CONFIG_SSHD"
  sed -i -e 's/#AllowTcpForwarding.*/AllowTcpForwarding no/' "$CONFIG_SSHD"
  sed -i -e 's/#GatewayPorts.*/GatewayPorts no/' "$CONFIG_SSHD"
  sed -i -e 's/X11Forwarding.*/X11Forwarding no/' "$CONFIG_SSHD"
  sed -i -e 's/#PrintLastLog.*/PrintLastLog yes/' "$CONFIG_SSHD"
  sed -i -e 's/#TCPKeepAlive.*/TCPKeepAlive no/' "$CONFIG_SSHD"
  sed -i -e 's/#PermitUserEnvironment.*/PermitUserEnvironment no/' "$CONFIG_SSHD"
  sed -i -e 's/#Compression.*/Compression no/' "$CONFIG_SSHD"
  sed -i -e 's/#ClientAliveCountMax.*/ClientAliveCountMax 2/' "$CONFIG_SSHD"
  sed -i -e 's/#ClientAliveInterval.*/ClientAliveInterval 300/' "$CONFIG_SSHD"
  sed -i -e 's/#UseDNS.*/UseDNS no/' "$CONFIG_SSHD"
  sed -i -e 's/#MaxStartups.*/MaxStartups 10:30:60/' "$CONFIG_SSHD"
  sed -i -e 's/#PermitTunnel.*/PermitTunnel no/' "$CONFIG_SSHD"
  sed -i -e 's/#IgnoreUserKnownHosts.*/IgnoreUserKnownHosts yes/' "$CONFIG_SSHD"
  sed -i -e 's/#HostbasedAuthentication.*/HostbasedAuthentication no/' "$CONFIG_SSHD"
  sed -i -e 's/#KerberosAuthentication.*/KerberosAuthentication no/' "$CONFIG_SSHD"
  sed -i -e 's/#GSSAPIAuthentication.*/GSSAPIAuthentication no/' "$CONFIG_SSHD"
  sed -i -e 's/.*Subsystem.*sftp.*/Subsystem sftp internal-sftp/' "$CONFIG_SSHD"
  echo "
  AllowGroups sshd_users
  KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr
  Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
  " >> "$CONFIG_SSHD"
  systemctl restart sshd.service
  #echo "Welcome" > /etc/issue.net
  #sudo ufw allow 31000/udp
  #sudo ufw allow 31000/tcp
  sudo ufw allow 31000
  sudo ufw allow 22000/udp
  sudo ufw allow 22000/tcp
  sudo ufw allow 22000
  sudo ufw allow 24563/udp
  sudo ufw allow 24563/tcp
  sudo ufw allow 24563
  sudo ufw allow 22
  sudo ufw allow ssh
  sudo ufw allow 22/tcp
  sudo ufw allow 22/udp
  sudo service ssh restart
  echo "SSH configured -- also try sshd_config2 (located in preconfig files dir) if you miss something" >> ~/script.log
fi

#chmod and file perms
chattr -i /etc/passwd
chattr -i /etc/shadow
chattr -i /etc/group
chattr -i /etc/login.defs
sudo chmod 640 .bash_history
sudo chmod 600 /etc/shadow
sudo chmod 640 /etc/passwd
sudo chmod 600 /etc/grub.d/
sudo chmod 700 ~/.ssh/
sudo chmod 644 ~/.ssh/id_rsa.pub
sudo chmod 600 ~/.ssh/authorized_keys
chmod 644 /etc/group
chmod o-rwx,g-rw /etc/gshadow
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-
chown root:shadow /etc/shadow-
chmod o-rwx,g-rw /etc/shadow-
chown root:root /etc/group-
chmod u-x,go-wx /etc/group-
chown root:shadow /etc/gshadow-
chmod o-rwx,g-rw /etc/gshadow-
chown root:root /etc/issue
chmod 644 /etc/issue
echo "#Authorized use only. All activity is being monitored and reported." >> /etc/issue
chown root:root /etc/issue.net
chmod 644 /etc/issue.net
chmod 640 /etc/sysctl.conf
chattr -R -i /etc/pam.d/*
chmod 640 /etc/pam.d/common-password /etc/pam.d/common-auth
chmod 640 /etc/ssh/sshd_config
echo "chmod complete" >> ~/script.log

#rc.local file secured
cd /etc
cp /etc/rc.local ~/Desktop/backups
rm rc.local
touch rc.local
sudo echo 'exit 0' >> /etc/rc.local
clear
echo "rc.local secured" >> ~/script.log

#/etc/adduser.conf configs:
#echo "DHOME=/home" >> /etc/adduser.conf
#echo "DSHELL=/bin/bash" >> /etc/adduser.conf
#echo "FIRST_SYSTEM_UID=100" >> /etc/adduser.conf
#echo "LAST_SYSTEM_UID=999" >> /etc/adduser.conf
#echo "FIRST_SYSTEM_GID=100" >> /etc/adduser.conf
#echo "FIRST_UID=1000" >> /etc/adduser.conf
#echo "LAST_UID=299999" >> /etc/adduser.conf
#echo "FIRST_GID=1000" >> /etc/adduser.conf
#echo "EXPIRE=30" >> /etc/default/useradd
#echo "INACTIVE=30" >> /etc/default/useradd
#echo "/etc/adduser.conf configured" >> ~/script.log

#/etc/deluser.conf configs:
#echo "REMOVE_HOME=1" >> /etc/deluser.conf
#echo "REMOVE_USR_GROUP=1" >> /etc/deluser.conf
#echo "REMOVE_ALL_FILES=1" >> /etc/deluser.conf
#echo "/etc/deluser.conf configured" >> ~/script.log

#/etc/hosts file configs:
chattr -i /etc/hosts.deny
chattr -i /etc/hosts.allow
chattr -i /etc/hosts
sudo echo -e "127.0.0.1 localhost\n127.0.1.1 $USER\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" >> /etc/hosts
sudo chmod 644 /etc/hosts
echo "ALL: LOCAL, 127.0.0.1" >> /etc/hosts.allow
echo "sshd : ALL : ALLOW" >> /etc/hosts.allow
echo "ALL: ALL" >> /etc/hosts.deny
chmod 644 /etc/hosts.allow
chmod 644 /etc/hosts.deny
chown root:root /etc/hosts.allow
chown root:root /etc/hosts.deny
echo "/etc/hosts configured" >> ~/script.log

# configuring /etc/login.defs
#echo "PASS_MAX_DAYS 15" >> /etc/login.defs
#echo "PASS_MIN_DAYS 7" >> /etc/login.defs
#echo "PASS_WARN_AGE 7" >> /etc/login.defs
#echo "PASS_MIN_LEN 8" >> /etc/login.defs
#echo "FAILLOG_ENAB yes" >> /etc/login.defs
#echo "LOG_UNKFAIL_ENAB yes" >> /etc/login.defs
#echo "LOG_OK_LOGINS yes" >> /etc/login.defs
#echo "UID_MIN 1000" >> /etc/login.defs
#echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
#echo "ENCRYPT_PASSWORDS yes" >> /etc/login.defs
#echo "UMASK 077" >> /etc/login.defs
#echo "LOG_INVALID_PASSWORDS yes" >> /etc/login.defs
#echo "LOG_PASSWORD_CHANGE yes" >> /etc/login.defs
#echo "LOG_PASSWORD_RESET yes" >> /etc/login.defs
#echo "SYSLOG_SU_ENAB yes" >> /etc/login.defs
#echo "SYSLOG_SG_ENAB yes" >> /etc/login.defs
#sed 's/FAKE_SHELL/d' /etc/login.defs
#clear
#rm /etc/login.defs
mv ~/pre-configured-files/login.defs /etc/login.defs
echo "/etc/login.defs secured" >> ~/script.log

#lightdm configs (disables guest)
echo "Would you like to install/config lightdm? y/n"
read lightdm
if [ $lightdm == "y" ] || [ $lightdm == "Y" ]; then
  sudo apt install lightdm -y
  chattr -i /etc/lightdm/lightdm.conf
  rm /etc/lightdm/lightdm.conf
  touch /etc/lightdm/lightdm.conf
  echo "[SeatDefaults]" >> /etc/lightdm/lightdm.conf
  echo "greeter-hide-users=true" >> /etc/lightdm/lightdm.conf
  echo "greeter-show-manual-login=true" >> /etc/lightdm/lightdm.conf
  echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
  sudo chmod 644 /etc/lightdm/lightdm.conf
  echo "Lightdm guest disabled, chmod 644 on lightdm.conf" >> ~/script.log
fi
chattr -R -i /etc/grub.d/*
echo "check_signatures=enforce" >> /etc/grub.d/40_custom
echo "superusers="root"" >> /etc/grub.d/40_custom

#disable ctrl-alt-delete
systemctl mask ctrl-alt-del.target

sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' /etc/systemd/system.conf
systemctl status ctrl-alt-del.target --no-pager > ~/sysctlctrlaltdel.txt
#sudo cp /etc/init.d/control-alt-delete.conf ~/Desktop/backups/
#sed -i '/exec shutdown -r not "Control-Alt-Delete pressed"/#exec shutdown -r not "Control-Alt-Delete pressed"/' /etc/init/control-alt-delete.conf
#sudo sed '/^exec/ c\exec false' /etc/init.d/control-alt-delete.conf
#clear
#echo "Ctrl-Alt-Delete disabled." >> ~/script.log
cp /etc/default/irqbalance ~/Desktop/backups/
echo > /etc/default/irqbalance
echo -e "#Configuration for the irqbalance daemon\n\n#Should irqbalance be enabled?\nENABLED=\"0\"\n#Balance the IRQs only once?\nONESHOT=\"0\"" >> /etc/default/irqbalance
echo "IRQ Balance has been disabled." >> ~/script.log

sudo ufw allow 80/tcp &&  sudo ufw allow 443/tcp
#/etc/sudoers.d
echo "Now showing /etc/sudoers.d"
touch sudoersdfiles.txt
cd /etc/sudoers.d/
ls -al >> ~/lssudoersd
cat /etc/sudoers.d/* >> sudoersdfiles.txt
echo "check sudoersdfiles.txt for files in the sudoers.d directory"
cd ~
sudo visudo

#apt-get -y -qq install git 
#cd
#git clone https://github.com/pyllyukko/user.js -q
#cd user.js
#cp user.js ~/.mozilla/firefox/XXXXXXXX.your_profile_name/user.js #CHANGE BEFORE RUNNING!!!!
#make systemwide_user.js
#cp systemwide_user.js /etc/firefox/syspref.js #Might be /etc/firefox/firefox.js on older Ubuntu versions
#echo "Firefox hardened." >> ~/script.log

#configuring /etc/resolv.conf
cp /etc/resolv.conf ~/Desktop/backups/
echo -e "nameserver 8.8.8.8\nsearch localdomain" >> /etc/resolv.conf
echo "resolv.conf has been configured." >> ~/script.log

#ftp configs
#cat ~/pre-configured-files/vsftpd.conf > /etc/vsftpd.conf

#check environmental variables
cd ~
env > env.txt
printenv >> env.txt

#hidepid hardening
echo "proc            /proc           proc    defaults,hidepid=1   0    0" >> /etc/fstab
touch /etc/systemd/system/systemd-logind.service.d/hidepid.conf
echo "[Service]\nSupplementaryGroups=proc" >> /etc/systemd/system/systemd-logind.service.d/hidepid.conf
echo "hidepid hardened" >> ~/script.log
#modprobe shit
echo "blacklist usb_storage" >> /etc/modprobe.d/blacklist.conf
echo "modprobe -r usb_storage\nexit 0" >> /etc/rc.local
modprobe -n -v cramfs | grep 'install /bin/true'
modprobe -n -v freevxfs | grep 'install /bin/true'
modprobe -n -v hfs | grep 'install /bin/true'

echo "Do you want to start updates (more stuff in misc.sh)? y/n"
read fquestion
if [ $fquestion == "n" ] || [ $fquestion == "N" ]; then
  exit 1
  echo "Configs script completed." >> ~/script.log
fi

dpkg-reconfigure -plow unattended-upgrades
#/etc/apt/apt.conf.d/20auto-upgrades:
echo "APT::Periodic::Update-Package-Lists “1”;" > /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Download-Upgradeable-Packages “1”;" >> /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::AutocleanInterval “7”;" >> /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Unattended-Upgrade “1”;" >> /etc/apt/apt.conf.d/20auto-upgrades

echo "Configs script completed." >> ~/script.log

