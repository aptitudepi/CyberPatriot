#!/bin/bash
#all aperture
echo "enter the main user of this system (readme)"
read user
#screen timeout policy
sudo -u $user gsettings set org.gnome.desktop.session idle-delay 300

#auto screen lock
sudo -u $user gsettings set org.gnome.desktop.screensaver lock-enabled true

#root acc locked
passwd -l root

#allow apache secure thru ufw
sudo ufw allow 'Apache Secure'

#pam dictcheck and usercheck
echo "usercheck = 1" >> /etc/security/pwquality.conf
echo "dictcheck = 1" >> /etc/security/pwquality.conf

#check /etc/hosts for extra hosts
echo "check /etc/hosts for extra hosts"
nano /etc/hosts

#apache
echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf
echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
echo "ServerSignature Off" >> /etc/apache2/apache2.conf

#check malicious apt repos
echo "check ~/ for the bad apt repos"
echo "apt.conf.d" > ~/badaptrepos.txt
ls -la /etc/apt/apt.conf.d/ >> ~/badaptrepos.txt
echo "sources.list.d" >> ~/badaptrepos.txt
ls -la /etc/apt/sources.list.d/ >> ~/badaptrepos.txt
sleep 10

#vsftpd 
echo "if vsftpd is a crit serv, check this"
sleep 2
nano /etc/vsftpd.chroot_list
cat /etc/vsftpd.chroot_list > ~/vsftpdchroot.txt


#systemctl unnecessary services
systemctl disable cups-browsed
systemctl disable avahi-daemon
systemctl stop cups-browsed
systemctl stop avahi-daemon

#find bad kernel modules
echo "finding kernel modules"
find /usr/lib/modules/ -name *.ko
find /usr/lib/modules/ -name *.ko > ~/kernelmodules.txt
sleep 10

#auditd check
echo "local_events = yes" >> /etc/audit/auditd.conf

#misc, but whatever
#sudo per tty basis
echo "add this to sudo visudo:"
echo "Defaults        requiretty"
sleep 10
