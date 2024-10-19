#!/bin/bash
#grub stuff
# Set the owner and group of /etc/grub.conf to the root user:
chown root:root /etc/grub.conf
chown -R root:root /etc/grub.d
# Set permissions on the /etc/grub.conf or /etc/grub.d file to read and write for root only:
chmod og-rwx /etc/grub.conf
chmod -R og-rwx /etc/grub.d
chattr -i /etc/default/grub
chattr -R -i /etc/grub.d/*
chmod 400 /boot/grub/grub.cfg
cp /etc/default/grub ~/Desktop/Backups/grub
echo "set check_signatures=enforce" >> /etc/grub.d/40_custom
echo "superusers="root"" >> /etc/grub.d/40_custom

#echo GRUB_CMDLINE_LINUX_DEFAULT="slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 quiet loglevel=0 spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 quiet loglevel=0" >> /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 quiet loglevel=0/g' /etc/default/grub
echo "set check_signatures=enforce" >> /etc/grub.d/40_custom
echo "export check_signatures" >> /etc/grub.d/40_custom
echo 'set superusers="root"' >> /etc/grub.d/40_custom
echo "export superusers" >> /etc/grub.d/40_custom
sudo grub-mkpasswd-pbkdf2
echo "take this output and put into file -- you have 10 seconds -- after the line password_pbkdf2 root "
sleep 10
sudo nano /etc/grub.d/40_custom
#echo "password_pbkdf2 root grub.pbkdf2.sha512.10000.TODO" >> /etc/grub.d/40_custom
sudo update-grub
echo "grub configured" >> ~/script.log

#dev sruff
chattr -i /etc/fstab
echo "tmpfs /run/shm tmpfs defaults,nodev,noexec,nosuid 0 0" >> /etc/fstab
echo "tmpfs   /dev/shm    tmpfs   noexec,nosuid,nodev 0   0" >> /etc/fstab
echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nodev,noexec,nosuid 0 0" >> /etc/fstab
echo "tmpfs           /run/shm        tmpfs   defaults        0       0" >> /etc/fstab
echo "proc /proc proc nosuid,nodev,noexec,hidepid=2,gid=proc 0 0" >> /etc/fstab
echo "LABEL=/boot  /boot  ext2  defaults,nodev,nosuid,noexec,ro  1 2" >> /etc/fstab
echo "tmpfs  /dev/shm  tmpfs  rw,nodev,nosuid,noexec,size=1024M,mode=1777 0 0" >> /etc/fstab
echo "tmpfs /tmp tmpfs defaults,nosuid,nodev,mode=1777,size=100M 0 0" >> /etc/fstab
echo "/tmp /var/tmp tmpfs defaults,nosuid,nodev,bind,mode=1777,size=100M 0 0" >> /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
echo "LABEL=/boot /boot ext2 defaults,ro 1 2"
mount -o remount /dev/shm
sed -i '/floppy/d' /etc/fstab
mount -a
local TMPFSTAB
touch /etc/systemd/system/systemd-logind.service.d/hidepid.conf
echo """
[Service]
SupplementaryGroups=proc
""" >> /etc/systemd/system/systemd-logind.service.d/hidepid.conf
cp ./config/tmp.mount /etc/systemd/system/tmp.mount
cp /etc/fstab /etc/fstab.bck
TMPFSTAB=$(mktemp --tmpdir fstab.XXXXX)
sed -i '/floppy/d' /etc/fstab
grep -v -E '[[:space:]]/boot[[:space:]]|[[:space:]]/home[[:space:]]|[[:space:]]/var/log[[:space:]]|[[:space:]]/var/log/audit[[:space:]]|[[:space:]]/var/tmp[[:space:]]' /etc/fstab > "$TMPFSTAB"
if grep -q '[[:space:]]/boot[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
  grep '[[:space:]]/boot[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev/g' >> "$TMPFSTAB"
fi

if grep -q '[[:space:]]/home[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
  grep '[[:space:]]/home[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev/g' >> "$TMPFSTAB"
fi

if grep -q '[[:space:]]/var/log[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
  grep '[[:space:]]/var/log[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev,noexec/g' >> "$TMPFSTAB"
fi

if grep -q '[[:space:]]/var/log/audit[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
  grep '[[:space:]]/var/log/audit[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev,noexec/g' >> "$TMPFSTAB"
fi

if grep -q '[[:space:]]/var/tmp[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
  grep '[[:space:]]/var/tmp[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev,noexec/g' >> "$TMPFSTAB"
fi

cp "$TMPFSTAB" /etc/fstab

if ! grep -q '/run/shm ' /etc/fstab; then
  echo 'none /run/shm tmpfs rw,noexec,nosuid,nodev 0 0' >> /etc/fstab
fi

if ! grep -q '/dev/shm ' /etc/fstab; then
  echo 'none /dev/shm tmpfs rw,noexec,nosuid,nodev 0 0' >> /etc/fstab
fi

if ! grep -q '/proc ' /etc/fstab; then
  echo 'none /proc proc rw,nosuid,nodev,noexec,relatime,hidepid=2 0 0' >> /etc/fstab
fi

if [ -e /etc/systemd/system/tmp.mount ]; then
  sed -i '/^\/tmp/d' /etc/fstab

  for t in $(mount | grep "[[:space:]]/tmp[[:space:]]" | awk '{print $3}'); do
    umount "$t"
  done
  sed -i '/[[:space:]]\/tmp[[:space:]]/d' /etc/fstab
  ln -s /etc/systemd/system/tmp.mount /etc/systemd/system/default.target.wants/tmp.mount
  sed -i 's/Options=.*/Options=mode=1777,strictatime,noexec,nodev,nosuid/' /etc/systemd/system/tmp.mount

  chmod 0644 /etc/systemd/system/tmp.mount

  systemctl daemon-reload
else
  echo '/etc/systemd/system/tmp.mount was not found.'
fi

sudo mount -a

#maybe try these
#none /run/shm tmpfs defaults,ro 0 0
#none /run/shm tmpfs rw,noexec,nosuid,nodev 0 0

#usb stuff
service autofs stop
chattr -i /etc/modprobe.conf
chattr -R -i /etc/modprobe.d/*
echo "install usb-storage /bin/true" >> /etc/modprobe.conf
gconftool-2 --direct \
--config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
--type bool \
--set /desktop/gnome/volume_manager/automount_drives false
gconftool-2 --direct \
--config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
--type bool \
--set /desktop/gnome/volume_manager/automount_media false
echo "Automatic mounting has been disabled." >> ~/script.log

#check /dev
cd /dev
ls -al > ~/devls.txt
cd ~

local MOD
MOD="bluetooth bnep btusb cpia2 firewire-core floppy n_hdlc net-pf-31 pcspkr soundcore thunderbolt usb-midi usb-storage uvcvideo v4l2_common"
for disable in $MOD; 
do  
  if ! grep -q "$disable" /etc/modprobe.d/disablemod.conf 2> /dev/null; then
    echo "install $disable /bin/true" >> /etc/modprobe.d/disablemod.conf
  fi
done
echo "Disabled misc kernel modules" >> ~/script.log

#disable other filesystems
local FS
FS="cramfs freevxfs jffs2 hfs hfsplus udf"
for disable in $FS; do
  if ! grep -q "$disable" /etc/modprobe.d/disablefs.conf 2> /dev/null; then
    echo "install $disable /bin/true" >> /etc/modprobe.d/disablefs.conf
  fi
done
echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf
echo 'install usb-storage /bin/true' >> /etc/modprobe.d/disable-usb-storage.conf
local HASHSIZE
local LOCKDOWN
HASHSIZE="/sys/module/nf_conntrack/parameters/hashsize"
LOCKDOWN="/sys/kernel/security/lockdown"

if [[ -f "$HASHSIZE" && -w "$HASHSIZE" ]]; then
  echo 1048576 > /sys/module/nf_conntrack/parameters/hashsize
fi

if [[ -f "$LOCKDOWN" && -w "$LOCKDOWN" ]]; then
 if ! grep -q 'lockdown=' /proc/cmdline; then
  echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX lockdown=confidentiality\"" > "$DEFAULTGRUB/99-hardening-lockdown.cfg"
 fi
fi
echo """
install dccp /bin/false
install sctp /bin/false
install rds /bin/false
install tipc /bin/false
install n-hdlc /bin/false
install ax25 /bin/false
install netrom /bin/false
install x25 /bin/false
install rose /bin/false
install decnet /bin/false
install econet /bin/false
install af_802154 /bin/false
install ipx /bin/false
install appletalk /bin/false
install psnap /bin/false
install p8023 /bin/false
install p8022 /bin/false
install can /bin/false
install atm /bin/false
install cramfs /bin/false
install freevxfs /bin/false
install jffs2 /bin/false
install hfs /bin/false
install hfsplus /bin/false
install squashfs /bin/false
install udf /bin/false
install cifs /bin/true
install nfs /bin/true
install nfsv3 /bin/true
install nfsv4 /bin/true
install ksmbd /bin/true
install gfs2 /bin/true
install bluetooth /bin/false
install btusb /bin/false
install uvcvideo /bin/false
install vivid /bin/false
""" > /etc/modprobe.d/securemodprobe
echo "Disable misc file systems" >> ~/script.log
#hardened malloc
git clone https://github.com/GrapheneOS/hardened_malloc
echo "reboot now? (y/n)"
read fquestion
sudo update-grub
if [ $fquestion == "n" ] || [ $fquestion == "N" ]; then
  exit 1
fi
reboot

