#!/bin/bash
chattr -R -i /etc/pam.d/*
chmod 640 /etc/pam.d/common-password /etc/pam.d/common-auth
apt-get install libpam-pwquality -y   # use pwquality instead of cracklib since cracklib is deprecated
#apt install -y libpam-cracklib
cat ~/pre-configured-files/common-password > /etc/pam.d/common-password
echo "Configured /etc/pam.d/common-password." >> ~/script.log
cat ~/pre-configured-files/common-auth > /etc/pam.d/common-auth
echo "Configured /etc/pam.d/common-auth." >> ~/script.log
clear
authconfig --passalgo=sha512 \
--passminlen=14 \
--passminclass=4 \
--passmaxrepeat=2 \
--passmaxclassrepeat=2 \
--enablereqlower \
--enablerequpper \
--enablereqdigit \
--enablereqother \
--update
#this disables remote login (ssh, telnet, etc.)
touch /etc/nologin
echo "account   required    pam_nologin.so" >> /etc/pam.d/sshd
echo "if you want to set limits to login through ssh and stuff, just edit that in /etc/security/limits.conf"
echo "auth required pam_listfile.so item=user sense=deny file=/etc/ssh/sshd.deny onerr=succeed"
touch /etc/ssh/sshd.deny
echo "root" >> /etc/ssh/sshd.deny
echo "enter the users that you want to deny ssh access to in the /etc/ssh/sshd.deny file"
