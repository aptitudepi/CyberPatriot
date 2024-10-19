#!/bin/bash
#change root password:
#echo "Change the root password" >> ~/script.log
#passwd
#remove fakeshell
#firefox https://github.com/konstruktoid/hardening
getent > ~/usersthatarentinpasswd.txt
chattr -i /bin/bash
chattr -R -i /etc/systemd/*
chattr -R -i /etc/systemd/system/*
rm /bin/fakeshell
chown root:root /etc/ssh/sshd_config
##Find SUID and SGID files
touch suid.txt
find / -perm /4000 >> suid.txt
touch sgid.txt
find / -perm /2000 >> sgid.txt
touch bothsuidandsgid.txt
find / -perm /6000 >> bothsuidandsgid.txt
touch setuidperms.txt
find / -user root -perm -4000 -exec ls -ldb {} \; > setuidperms.txt 
touch instructions_for_suid_sgid.txt
chmod ugo-s /bin/nano
chmod ugo-s /bin/bash
#still have to test
if ! [ -f ./suid.list ]; then
  echo "The list with SUID binaries can't be found."
else
  while read -r suid; do
    file=$(command -v "$suid")
    if [ -x "$file" ]; then
      if stat -c "%A" "$file" | grep -qi 's'; then
        if [[ $VERBOSE == "Y" ]]; then
          echo "$file"
        fi
      fi
      chmod -s "$file"
      oct=$(stat -c "%A" "$file" | sed 's/s/x/g')
      ug=$(stat -c "%U %G" "$file")
      dpkg-statoverride --remove "$file" 2> /dev/null
      dpkg-statoverride --add "$ug" "$oct" "$file" 2> /dev/null
    fi
  done <<< "$(grep -E '^[a-zA-Z0-9]' ./suid.list)"
fi
while read -r suidshells; do
  if [ -x "$suidshells" ]; then
    chmod -s "$suidshells"
      
    if [[ $VERBOSE == "Y" ]]; then
      echo "$suidshells"
    fi
  fi
done <<< "$(grep -v '^#' /etc/shells)"
echo "RUN: chmod u-s file_name\nThis will remove SUID from a file" >> instructions_for_suid_sgid.txt
echo "RUN: chmod g-s file_name\nThis will remove SGID from a file" >> instructions_for_suid_sgid.txt
echo "https://www.thegeekdiary.com/linux-unix-how-to-find-files-which-has-suid-sgid-set/" >> instructions_for_suid_sgid.txt
echo "found and reported SUID and SGID files" >> ~/script.log

#check sudo perms
sudo -l > ~/sudopermslist.txt

#/etc/skel recon
cd /etc/skel
ls -al > ~/etcskellrecon.txt
cd ~

#Check if checksums of binaries and config files are valid
#sudo apt install debsums -y
#cd ~
#touch debsums.txt
#debsums -a >> ~/debsums.txt
#debsums -c > ~/debsums2.txt

#remove unauth and useless packages
#sudo apt-get install deborphan -y
#touch deborphansearch.txt
#deborphan --guess-all >> deborphansearch.txt
#deborphan --guess-data | xargs sudo apt-get -y autoremove --purge
#deborphan | xargs sudo apt-get -y autoremove --purge

#fix bug in openssl
sudo apt-get upgrade openssl libssl-dev -y
sudo apt-cache policy openssl libssl-dev -y
sudo apt-get upgrade openssl libssl-doc -y
sudo apt-cache policy openssl libssl-doc -y
echo "openssl heartbleed vuln patched" >> ~/script.log

#crontab perms
chattr -R -i /etc/cron.d/*
chattr -i /etc/crontab
chattr -R -i /var/spool/cron/crontabs/*
chattr -R -i /var/spool/cron/*
chattr -i /etc/cron*
crontab -r
cd /etc/
/bin/rm -f cron.deny at.deny
echo root > cron.allow
echo root > at.allow
/bin/chown root:root cron.allow at.allow
/bin/chmod 400 cron.allow at.allow
cd ~
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
sudo service cron restart
echo "cron perms set" >> ~/script.log
clear

#checking backdoors in crontabs
cd ~
touch backdoors.txt
if [ cat /var/spool/cron/crontabs/* | grep * * * * * ]; then
    echo "Found unwanted crontabs in /var/spool/cron/crontabs here: ${cat /var/spool/cron/crontabs/* | grep -c * * * * *}" >> backdoors.txt
fi
if [[ $(cat /etc/crontab | grep -q -c "* * * * *" | wc -l) -ge  2 ]]; then
    echo "Found malicious crontab in /etc/crontab." >> backdoors.txt
fi
if [ cat /etc/cron.d/* /etc/cron.d/.* | grep * * * * * ]; then
    echo "Found unwanted crontabs in /etc/cron.d/ here: ${cat /etc/cron.d/* | grep -c * * * * *}" >> backdoors.txt
fi
crontab -l > ~/Desktop/backups/crontab-old
crontab -r
echo "Crontab backed up. All startup tasks removed from crontab." >> ~/script.log

#list processes
ps aux > ~/psaux.txt
ps auxf > ~/psauxf.txt
sudo lsof -i -P -n | grep LISTEN > ~/lsoflisten.txt

cd /etc/
/bin/rm -f cron.deny at.deny
echo root > cron.allow
echo root > at.allow
/bin/chown root:root cron.allow at.allow
/bin/chmod 400 cron.allow at.allow
cd ~
echo "Only root is allowed in cron." >> ~/script.log

#check for backdoors w/ networking
cd ~
touch listening.txt
green="\e[1;32m"
nocolor="\e[0m"
sudo apt-get install net-tools -y
echo "$(netstat -tulpn | grep -i "LISTEN")\n${green}The ports above are listening.${nocolor}\n" >> listening.txt
ss -tulpn > listening2.txt
sudo service cron restart
clear
echo "Crontabs secured" >> ~/script.log

#hosts stuff
echo "sshd : ALL : ALLOW" >> /etc/hosts.allow
echo "ALL: LOCAL, 127.0.0.1" >> /etc/hosts.allow
echo "ALL: ALL" >> /etc/hosts.deny
chmod 644 /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.deny
chown root:root /etc/hosts.deny

#process stuff
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf

#check services
cd ~
touch servicecheck.txt
sudo service --status-all >> servicecheck.txt
echo "check servicecheck.txt in ~ for list of running services" >> ~/script.log

#Searching other package managers
cd ~
touch npm.txt
touch rpm.txt
touch snap.txt
touch pip.txt
touch pip3.txt
rpm -ql >> rpm.txt
npm list --prod >> npm.txt
npm list --dev >> npm.txt
snap list >> snap.txt
pip list >> pip.txt
pip3 list >> pip3.txt
yum list installed > ~/yum.txt
echo "check root home dir for snap, rpm, pip, pip3, yum, and npm recon files" >> ~/script.log

cd ~
touch aliases.txt
alias >> aliases.txt
unalias -a
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
echo "aliases reset to original" >> ~/script.log
clear

#check /opt for malicious scripts and files
cd ~
touch opt_dir_contents.txt
ls -la /opt >> opt_dir_contents.txt

#/var/www/html and /var/log/mail
cd ~
touch varwwwhtml.txt
ls -la /var/www/html >> varwwwhtml.txt
touch varlogmail.txt
ls -la /var/log/mail >> varlogmail.txt

#check contents of /root
cd ~
touch slashroot.txt
ls -la /root >> slashroot.txt

#chechk /boot
ls -al /boot/ > ~/lsboot.txt
ls -al /boot/grub/ > ~/lsbootgrub.txt
ls -al /etc/init.d/ > ~/lsetcinitd.txt

echo "check stuff in /opt /root /var/www/html /var/log/mail and others" >> ~/script.log

#random stuff
install cramfs /bin/true
install hfs /bin/true
install hfsplus /bin/true
install squashfs /bin/true
install udf /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
clear

#disable auto mounting
service autofs stop
echo "install usb-storage /bin/true" >> /etc/modprobe.conf
echo "install usb-storage /bin/true" >> /etc/modprobe.d/block_usb.conf
gconftool-2 --direct \
--config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
--type bool \
--set /desktop/gnome/volume_manager/automount_drives false
gconftool-2 --direct \
--config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
--type bool \
--set /desktop/gnome/volume_manager/automount_media false
echo "Automatic mounting disabled." >> ~/script.log
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf

#restrict access to compiler
chmod o-rx /usr/bin/x86_64-linux-gnu-as > /dev/null
sudo chmod 644 /etc/syslog.conf
chmod 644 /etc/pam.d
chmod 644 /etc/group
chown root:root /etc/passwd
chown root:root /etc/group
chown root:root /etc/pam.d
chown root:shadow /etc/gshadow
chown root:shadow /etc/shadow
chmod 640 /etc/shadow
chmod 600 /etc/crontab
chmod 700 /etc/cron.d
chmod 700 /etc/cron.daily
chmod 700 /etc/cron.hourly
chmod 700 /etc/cron.monthly
chmod 700 /etc/cron.weekly

systemctl stop avahi-daemon.service &> /dev/null
systemctl stop avahi-daemon.socket &> /dev/null
apt purge -y avahi-daemon &> /dev/null

apt purge -y cups &> /dev/null
apt purge -y isc-dhcp-server &> /dev/null
apt purge -y slapd &> /dev/null
apt purge -y nfs-kernel-server &> /dev/null
apt purge -y dovecot-imapd &> /dev/null
apt purge -y dovecot-pop3d &> /dev/null
apt purge -y squid &> /dev/null
apt purge -y snmpd &> /dev/null
apt purge -y nis &> /dev/null
apt purge -y rsync &> /dev/null
apt purge -y rsh-client &> /dev/null
apt purge -y rsh-redone-client &> /dev/null
apt purge -y talk &> /dev/null
apt purge -y ntalk &> /dev/null
apt purge -y telnet &> /dev/null
apt purge -y ldap-utils &> /dev/null
apt purge -y rpcbind &> /dev/null

#ecryptfs stuff... Unsure if this is needed
#apt-get -y -qq install ecryptfs-utils cryptsetup
#sudo ecryptfs-migrate-home -u $USER
#echo "Filesystem encrypted." >> ~/script.log

#fixing shellshock vuln
touch shellshockcheck.txt
env 'VAR=() { :;}; echo Bash is vulnerable!' 'FUNCTION()=() { :;}; echo Bash is vulnerable!' bash -c "echo Bash Test" >> shellshockcheck.txt
echo "CHECK shellshocktext.txt and do sudo apt-get update && sudo apt-get install --only-upgrade bash if vulnerable" >> ~/script.log

#disable sysrq
cp /proc/sys/kernel/sysrq ~/Desktop/backups/
echo 0 > /proc/sys/kernel/sysrq
echo "The SysRq key has been disabled" >> ~/script.log
clear

#drop rst packets for sockets
cp /proc/sys/net/ipv4/tcp_rfc1337 ~/Desktop/backups/
echo 1 > /proc/sys/net/ipv4/tcp_rfc1337
echo "rst packets for sockets dropped by kernel." >> ~/script.log
clear

#change core_uses_pid
cp /proc/sys/kernel/core_uses_pid ~/Desktop/backups/
echo 1 > /proc/sys/kernel/core_uses_pid
echo "Kernel core_uses_pid is now set to 1." >> ~/script.log
clear

#log_martians is set to 1
cp /proc/sys/net/ipv4/conf/default/log_martians ~/Desktop/backups/
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians
echo "log_martians is now set to 1." >> ~/script.log
clear

#set tcp_timestamps to 0
cp /proc/sys/net/ipv4/tcp_timestamps ~/Desktop/backups/
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
echo "tcp_timestamps is now set to 0." >> ~/script.log
clear

#logs
mkdir -p ~/Desktop/logs
chmod 777 ~/Desktop/logs
echo "the logs folder can be found on Desktop." >> ~/script.log
touch ~/Desktop/logs/allusers.txt
uidMin=$(grep "^UID_MIN" /etc/login.defs)
uidMax=$(grep "^UID_MAX" /etc/login.defs)
echo -e "User Accounts:" >> ~/Desktop/logs/allusers.txt
awk -F':' -v "min=${uidMin##UID_MIN}" -v "max=${uidMax##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $0 }' /etc/passwd >> ~/Desktop/logs/allusers.txt
echo -e "\nSystem Accounts:" >> ~/Desktop/logs/allusers.txt
awk -F':' -v "min=${uidMin##UID_MIN}" -v "max=${uidMax##UID_MAX}" '{ if ( !($3 >= min && $3 <= max  && $7 != "/sbin/nologin")) print $0 }' /etc/passwd >> ~/Desktop/logs/allusers.txt
echo "All users are logged." >> ~/script.log
cp /etc/services ~/Desktop/logs/allports.log
echo "All ports are logged in allports.log" >> ~/script.log
dpkg -l > ~/Desktop/logs/packages.log
echo "All packages are logged in packages.log" >> ~/script.log
apt-mark showmanual > ~/Desktop/logs/manuallyinstalled.log
echo "all packages that were manually installed are logged" >> ~/script.log
service --status-all > ~/Desktop/logs/allservices.txt
echo "All running services are now logged" >> ~/script.log
ps auxf > ~/Desktop/logs/processes.log
echo "All running processes are logged" >> ~/script.log
ss -l > ~/Desktop/logs/socketconnections.log
echo "All socket connections are logged" >> ~/script.log
sudo netstat -tlnp > ~/Desktop/logs/listeningports.log
echo "All listening ports are logged" >> ~/script.log
cp /var/log/auth.log ~/Desktop/logs/auth.log
echo "auth.log is logged on Desktop" >> ~/script.log
cp /var/log/syslog ~/Desktop/logs/syslog.log
echo "syslog.log is logged on Desktop" >> ~/script.log
chmod 777 -R ~/Desktop/backups
chmod 777 -R ~/Desktop/logs
clear

#finding files of all high perms on system
touch ~/Desktop/perms.log
echo "finding files (this may take a while)...pls wait"
for i in {700..777};
do
    find / -type f -perm $i >> ~/Desktop/perms.log
done
echo "File searching for high perm files complete! Check perms.log on Desktop." >> ~/script.log

#Disable rhosts
while read -r hostpasswd; do
  find "$hostpasswd" \( -name "hosts.equiv" -o -name ".rhosts" \) -exec rm -f {} \; 2> /dev/null

done <<< "$(awk -F ":" '{print $6}' /etc/passwd)"

if [[ -f /etc/hosts.equiv ]]; then
  rm /etc/hosts.equiv
fi

#recon on init files
cd /etc/init.d
ls -al > ~/etcinitdrecon.txt
cd /etc/systemd/system
ls -al > ~/etcsystemdsystem.txt
cd /etc/systemd
ls -al > ~/etcsystemddir.txt
cd /boot
ls -al > ~/slashbootrecon.txt
cd ~
#systemctl
systemctl list-dependencies > ~/sysctlLIST.txt
systemctl list-unit-files >> ~/sysctlLIST.txt
systemctl list-machines >> ~/sysctlLIST.txt
systemctl list-jobs >> ~/sysctlLIST.txt
systemctl --state=failed > ~/sysctlFAILED.txt

#attributes
lsattr /* > ~/lsattrslash.txt
lsattr /etc/* > ~/lsattretc.txt
lsattr /home/* > ~/lsattrhome.txt

#checking who has shell access
cat /etc/passwd | grep "/bin/bash" > ~/etcpasswdshellcheck.txt
cat /etc/passwd | grep "/bin/zsh" >> ~/etcpasswdshellcheck.txt
cat /etc/passwd | grep "/bin/sh" >> ~/etcpasswdshellcheck.txt
cat /etc/passwd | grep "/bin/rbash" >> ~/etcpasswdshellcheck.txt

#X Server does not allow TCP connections -- gdm3
echo "
[security]
DisallowTCP=false

[xdmcp]
ServerArguments=-listen tcp
" >> /etc/gdm3/custom.conf

#removing prelink
if dpkg -l | grep prelink 1> /dev/null; then
  "$(command -v prelink)" -ua 2> /dev/null
  sudo apt-get autoremove --purge prelink
fi

#disable bad network processes
local NET
NET="dccp sctp rds tipc"
for disable in $NET; do
  if ! grep -q "$disable" "/etc/modprobe.d/disablenet.conf" 2> /dev/null; then
    echo "install $disable /bin/true" >> "/etc/modprobe.d/disablenet.conf"
  fi
done

#logrotate and journald
sed -i 's/^#Storage=.*/Storage=persistent/' /etc/systemd/journald.conf
sed -i 's/^#ForwardToSyslog=.*/ForwardToSyslog=yes/' /etc/systemd/journald.conf
sed -i 's/^#Compress=.*/Compress=yes/' /etc/systemd/journald.conf
systemctl restart systemd-journald

if [ -w /etc/rsyslog.conf ]; 
then
    sed -i "s/^\$FileCreateMode.*/\$FileCreateMode 0600/g" /etc/rsyslog.conf
fi

if [[ $VERBOSE == "Y" ]]; then
  systemctl status systemd-journald --no-pager
  echo
fi
echo "Systemd/journald.conf and logrotate.conf configured" >> ~/script.log

echo "
[Coredump]
Storage=none
" >> /etc/systemd/coredump.conf.d/disable.conf

echo "* hard core 0" >> /etc/security/limits.conf

echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login


if command -v gsettings 2>/dev/null 1>&2; then
  gsettings set com.ubuntu.update-notifier show-apport-crashes false
fi

if command -v ubuntu-report 2>/dev/null 1>&2; then
  ubuntu-report -f send no
fi

if [ -f /etc/default/apport ]; then
  sed -i 's/enabled=.*/enabled=0/' /etc/default/apport
  systemctl stop apport.service
  systemctl mask apport.service
fi

if dpkg -l | grep -E '^ii.*popularity-contest' 2>/dev/null 1>&2; then
  apt-get purge popularity-contest
fi

systemctl daemon-reload

if [[ $VERBOSE == "Y" ]]; then
  systemctl status apport.service --no-pager
  echo
fi
echo "apport secured" >> ~/script.log 

#AIDE
sudo apt install aide -y
if ! grep -R -E '^!/var/lib/lxcfs/cgroup$' /etc/aide/*; then
  echo '!/var/lib/lxcfs/cgroup' > /etc/aide/aide.conf.d/70_aide_lxcfs
fi
if ! grep -R -E '^!/var/lib/docker$' /etc/aide/*; then
  echo '!/var/lib/docker' > /etc/aide/aide.conf.d/70_aide_docker
fi
echo "This may take a while ..."
aideinit --yes
if ! [ -f /etc/cron.daily/aide ]; then
  cp ~/aidecheck.service /etc/systemd/system/aidecheck.service
  cp ~/aidecheck.timer /etc/systemd/system/aidecheck.timer
  chmod 0644 /etc/systemd/system/aidecheck.*

  systemctl reenable aidecheck.timer
  systemctl restart aidecheck.timer
  systemctl daemon-reload

  if [[ $VERBOSE == "Y" ]]; then
    systemctl status aidecheck.timer --no-pager
    echo
  fi
fi
aideinit
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
prelink -ua

(cat /etc/systemd/system/aidecheck.service ; echo " [Unit] 
Description=Aide check every day at 5AM
 [Timer] 
OnCalendar=*-*-* 05:00:00 Unit=aidecheck.service
 [Install] 
WantedBy=multi-user.target") > aide_conf
cp aide_conf /etc/systemd/system/aidecheck.service
rm aide_conf

chown root:root /etc/systemd/system/aidecheck.* 
chmod 0644 /etc/systemd/system/aidecheck.* 
systemctl daemon-reload 
systemctl enable aidecheck.service 
systemctl --now enable aidecheck.timer

#/etc/resolv.conf
chattr -i /etc/resolv.conf
apt install resolvconf -y
systemctl start resolvconf.service
systemctl enable resolvconf.service

sed -i 's/FAIL_DELAY.*/FAIL_DELAY    5/' /etc/login.defs
sed -i 's/DENY_THRESHOLD_INVALID.*/DENY_THRESHOLD_INVALID    5/' /etc/pam.d/common-auth
sed -i 's/DENY_THRESHOLD_VALID.*/DENY_THRESHOLD_VALID    5/' /etc/pam.d/common-auth
sed -i 's/DENY_THRESHOLD_ROOT.*/DENY_THRESHOLD_ROOT    5/' /etc/pam.d/common-auth
sed -i 's/AUTH_TIMEOUT.*/AUTH_TIMEOUT    1800/' /etc/pam.d/common-auth

#find text in certain files
echo -n "enter text to find and the directory you want to find it in (separated by a colon -- text first and then dir)"
read $inputstr
ls -laR "$(echo $inputstr | cut -d ":" -f 2)" | grep -rins "$(echo $inputstr | cut -d ":" -f 1)"

#selinux
apt install policycoreutils selinux-utils selinux-basics -y
selinux-activate
selinux-config-enforcing

echo "/var/log/auth.log {
  rotate 4
  weekly
  compress
  missingok
  notifempty
}" >> /etc/logrotate.d/auth
clear

echo "go to /etc/xinetd.d/ and go through each file. Find the disable = yes/no feature for each service you want to disable and set it to disable = yes"

#remount / with acl
echo -e "#remount / with acl\nthis may be risky...\nmount -o remount,acl /"
echo "alias net-pf-10 off" >> /etc/modprobe.d/aliases
echo "alias ipv6 off" >> /etc/modprobe.d/aliases
echo "misc script complete! Pls check ~ and Desktop for your files!" >> ~/script.log

