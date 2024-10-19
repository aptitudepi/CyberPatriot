#!/bin/bash
cd ~
mkdir recon
ls -al /root/ > ~/recon/slashroot.txt
ls -al /usr/lib/systemd/system/ > ~/recon/usrlibsystemdsystem.txt
ls -al /bin/ > ~/recon/slashbin.txt
ls -al /boot/ > ~/recon/slashboot.txt
ls -al /sbin/ > ~/recon/slashsbin.txt
ls -al /media/ > ~/recon/slashmedia.txt
ls -al /usr/share/ > ~/recon/slashusrshare.txt
cat /var/spool/cron/crontabs/* > ~/recon/crontabcheck.txt
ls -la /etc/cron.* > ~/recon/crondotstar.txt
cat /etc/rc.local > ~/recon/rclocalcheck.txt
apt install nmap -y
netstat -tulpenaw > ~/recon/netstat.txt
nmap -sV localhost -p- > ~/recon/nmapscan.txt
ps auxjf > ~/recon/psauxjf.txt
which bash > ~/recon/whichbash.txt
which sudo > ~/recon/whichsudo.txt
ls -al /etc/sudoers.d/ > ~/recon/sudoersd.txt
touch ~/recon/bashrcchecks.txt
for i in $(find / -name ".bashrc"); do echo "$i" >> ~/recon/bashrcchecks.txt; done
ls -al /var/www/html > ~/recon/varwwwhtml.txt
snap list > ~/recon/snapcheck.txt
#find files associated to users not on the system anymore
sudo find / -xdev -nouser
