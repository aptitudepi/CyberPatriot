#!/bin/bash
mkdir --mode 000 /tmp-inst
mkdir --mode 000 /var/tmp/tmp-inst
echo "
/tmp      /tmp-inst/          level  root,adm
/var/tmp  /var/tmp/tmp-inst/  level  root,adm
" >> /etc/security/namespace.conf
setsebool polyinstantiation_enabled=1
chcon --reference=/tmp /tmp-inst
chcon --reference=/var/tmp/ /var/tmp/tmp-inst

echo "tmpfs  /dev/shm  tmpfs  rw,nodev,nosuid,noexec,size=1024M,mode=1770,uid=root,gid=shm 0 0" >> /etc/fstab

echo "sdb1_crypt /dev/sdb1 /dev/urandom cipher=aes-xts-plain64,size=256,swap,discard" >> /etc/crypttab
echo "/dev/mapper/sdb1_crypt none swap sw 0 0" >> /etc/fstab

chown root:root /etc/grub.conf
chown -R root:root /etc/grub.d
chmod og-rwx /etc/grub.conf
chmod -R og-rwx /etc/grub.d

echo "kernel.dmesg_restrict = 1" > /etc/sysctl.d/50-dmesg-restrict.conf
echo "kernel.kptr_restrict = 1" > /etc/sysctl.d/50-kptr-restrict.conf
echo "kernel.exec-shield = 2" > /etc/sysctl.d/50-exec-shield.conf
echo "kernel.randomize_va_space=2" > /etc/sysctl.d/50-rand-va-space.conf

systemctl enable rsyslog
systemctl start rsyslog

echo "
# Edit /etc/pam.d/system-auth and /etc/pam.d/password-auth

# Add the following line immediately before the pam_unix.so statement in the AUTH section:
auth required pam_faillock.so preauth silent deny=3 unlock_time=never fail_interval=900

# Add the following line immediately after the pam_unix.so statement in the AUTH section:
auth [default=die] pam_faillock.so authfail deny=3 unlock_time=never fail_interval=900

# Add the following line immediately before the pam_unix.so statement in the ACCOUNT section:
account required pam_faillock.so
" > ~/dopamstuff.txt

echo "fs.protected_hardlinks = 1" > /etc/sysctl.d/50-fs-hardening.conf
echo "fs.protected_symlinks = 1" >> /etc/sysctl.d/50-fs-hardening.conf

echo "install cramfs /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install freevxfs /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install jffs2 /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install hfs /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install hfsplus /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install squashfs /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install udf /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install fat /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install vfat /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install nfs /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install nfsv3 /bin/false" > /etc/modprobe.d/uncommon-fs.conf
echo "install gfs2 /bin/false" > /etc/modprobe.d/uncommon-fs.conf

echo "SELINUXTYPE=enforcing" >> /etc/selinux/config

echo "net.ipv4.tcp_syncookies = 1" > /etc/sysctl.d/50-net-stack.conf
echo "net.ipv4.conf.all.accept_source_route = 0" > /etc/sysctl.d/50-net-stack.conf
echo "net.ipv4.conf.all.accept_redirects = 0" > /etc/sysctl.d/50-net-stack.conf
echo "net.ipv4.icmp_echo_ignore_all = 1" > /etc/sysctl.d/50-net-stack.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" > /etc/sysctl.d/50-net-stack.conf

