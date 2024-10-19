printf "install cramfs /bin/false blacklist cramfs" >> /etc/modprobe.d/cramfs.conf
modprobe -r cramfs

printf "install squashfs /bin/false blacklist squashfs" >> /etc/modprobe.d/squashfs.conf
modprobe -r squashfs
printf "install udf /bin/false blacklist udf " >> /etc/modprobe.d/udf.conf
modprobe -r udf
systemctl unmask tmp.mount

#fstab and grub
echo "running grubanddev.sh script"
chmod +x ~/grubanddev.sh
bash ~/grubanddev.sh
