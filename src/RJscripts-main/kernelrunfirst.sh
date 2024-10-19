echo "* hard core 0" > /etc/security/limits.conf
echo "tmpfs /run/shm tmpfs defaults,nodev,noexec,nosuid 0 0" >> /etc/fstab
echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nodev,noexec,nosuid 0 0" >> /etc/fstab
prelink -ua
apt-get remove -y prelink
systemctl mask ctrl-alt-del.target
systemctl daemon-reload

echo "" > /etc/updatedb.conf
echo "blacklist usb-storage" >> /etc/modprobe.d/blacklist.conf
echo "install usb-storage /bin/false" > /etc/modprobe.d/usb-storage.conf
echo $PATH > /etc/environment
#securetty and profile
echo "tty1" > /etc/securetty
echo "TMOUT=300" >> /etc/profile
echo "readonly TMOUT" >> /etc/profile
echo "export TMOUT" >> /etc/profile

mv /etc/profile /etc/profile.bak
mv ~/pre-configured-files/profile > /etc/profile
