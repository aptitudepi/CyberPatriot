chattr -i /etc/sudoers
chattr -i -R /etc/sudoers.d/*
chattr -i /etc/shadow /etc/gshadow /etc/group /etc/passwd
chmod 600 /etc/sudoers
chmod 600 /etc/sudoers.d/*
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/ssh/sshd_config
chmod 400 /etc/inetd.conf
chmod 400 /etc/xinetd.conf
chown root:root /etc/securetty
chown root:root /etc/passwd
chown root:root /etc/shadow
chattr -i /etc/passwd
chattr -i /etc/shadow
chattr -i /etc/group
chattr -i /etc/login.defs
chattr -i /etc/gshadow
sudo chmod 640 .bash_history
sudo chmod 600 /etc/shadow
sudo chmod 640 /etc/passwd
sudo chmod 600 /etc/grub.d/
sudo chmod 700 ~/.ssh/
sudo chmod 644 ~/.ssh/id_rsa.pub
sudo chmod 600 ~/.ssh/authorized_keys
chmod 640 /etc/ssh
chmod 700 ~/.ssh
chmod 644 ~/.ssh/rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/authorized_keys
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
chattr -i -R /etc/pam.d/*
chmod 640 /etc/pam.d/common-password /etc/pam.d/common-auth
chmod 640 /etc/ssh/sshd_config
chmod 400 /etc/inetd.conf
chmod ugo-s /bin/bash
chmod ugo-s /bin/sudo
chmod ugo-s /bin/sh
chmod ugo-s /bin/apt
chmod ugo-s /bin/nano
chmod 644 /etc/hosts.allow
chmod 644 /etc/hosts.deny
sudo chmod 644 /etc/lightdm/lightdm.conf
chown root:root /etc/grub.conf
chown -R root:root /etc/grub.d
chmod og-rwx /etc/grub.conf
chmod -R og-rwx /etc/grub.d
chattr -i /etc/default/grub
chattr -i -R /etc/grub.d/*
chmod 400 /boot/grub/grub.cfg
chmod 0644 /etc/systemd/system/tmp.mount
sudo chown root:root /var/log/mail*

#suid stuff
cat ~/suid.list | xargs > ~/suid.txt
for i in $(cat ~/suid.txt);
do
  chmod ugo-s /bin/"$i"
done
##keep adding
##ACL
getfacl -sR / > ~/fileswithacl.txt
getfacl -sR /etc/ /usr/ /root/ > ~/fileswithaclcritdirs.txt
touch ~/fileswithaclinstructions.txt
echo "use setfacl -x u:user::perms(ie rwx)" >> ~/fileswithaclinstructions.txt
