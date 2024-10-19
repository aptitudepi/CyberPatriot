#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

touch ~/script.log

# backups
mkdir -p ~/fedora/Desktop/backups/
chmod 700 ~/Desktop/backups/

cp /etc/passwd ~/fedora/Desktop/backups
cp /etc/group ~/fedora/Desktop/backups

#unattended upgrades
#cp auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
echo "go to GUI settings and turn off all notifications! Script will resume in 30 seconds..."
sleep 30
echo "now go to GUI privacy and turn off apps that you don't use with the toggle at the top. Also, under file history and trash, turn the file history toggle off and hit the red clear history button Script will resume in 30 seconds..."
sleep 30

#bash upgrade
sudo dnf install dnf-automatic
sudo dnf dnf-automatic
sudo dnf update
dnf install --only-upgrade bash
#kernel upgrade
dnf dist-upgrade
#remove unnecessary dependencies
dnf autoremove
#remove unsupported pkgs
dnf autoclean


# adduser.conf
#cp adduser /etc/adduser.conf

#deluser.conf (unsure)
#cp deluser /etc/deluser.conf

passwd -l root

#password policies
cp login.defs /etc/login.defs
apt install libpam-cracklib -y
#cp common-password /etc/pam.d/common-password
#cp common-auth /etc/pam.d/common-auth

#file perms
chmod 640 /etc/*

#crontabs
echo "CRONTABS HAVE BEEN FOUND IN:"
cat /etc/cron.d/* | grep -l "\* \* \* \* \*"
cat /etc/crontab | grep -l "\* \* \* \* \*"
cat /var/spool/cron/crontabs/* | grep "\* \* \* \* \*"
echo "END CRONTAB LIST"

#networking
systemctl unmask firewalld
systemctl start firewalld
mv ~/pre-configured-sysctl/sysctl.conf /etc/sysctl.conf
sysctl -p
cp resolv.conf /etc/resolv.conf
cp host.conf /etc/host.conf

#find filetypes
find / -name *.jpg > ~/fedora/mediafind.txt
find / -name *.png >> ~/fedora/mediafind.txt
find / -name *.mp3 >> ~/fedora/mediafind.txt
find / -name *.mp4 >> ~/fedora/mediafind.txt
find / -name *.wav >> ~/fedora/mediafind.txt
find / -name *.mov >> ~/fedora/mediafind.txt
find / -name *.gif >> ~/fedora/mediafind.txt
find / -name *.bmp >> ~/fedora/mediafind.txt
find / -name *.txt >> ~/fedora/mediafind.txt
#authconfig --passmaxdays=15 --passminlen=14 --passminclass=7 --passwarnage=7 --update

#list manually installed packages
dnf repoquery --userinstalled
