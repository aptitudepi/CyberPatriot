#!/bin/bash
#Updates:
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
#sudo dpkg -l | grep unattended-upgrades >> /dev/null
read -p "choose your version of ubuntu: 18, 20, or 22 OR deb11: " ubuver
if [[ $ubuver == "18" ]]; then
        cp /etc/apt/sources.list ~/sources.list.bak
        mv ~/pre-configured-files/ubu18/ubu18/sources.list /etc/apt/sources.list
elif [[ $ubuver == "20" ]]; then
        cp /etc/apt/sources.list ~/sources.list.bak        
        mv ~/pre-configured-files/ubu20/sources.list /etc/apt/sources.list
elif [[ $ubuver == "22" ]]; then
        cp /etc/apt/sources.list ~/sources.list.bak
        mv ~/pre-configured-files/ubu22/sources.list /etc/apt/sources.list
elif [[ $ubuver == "deb11" ]]; then
        cp /etc/apt/sources.list ~/sources.list.bak
        mv ~/pre-configured-files/deb11/sources.list /etc/apt/sources.list
fi
echo "firefox will be updated in the process"
sleep 10
CONFIG_AUTOUPDATE='/etc/apt/apt.conf.d/50unattended-upgrades'
sed -i -e 's/\/\/.*"\${distro_id}:\${distro_codename}-updates";/\t\"\${distro_id}:\${distro_codename}-updates\";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::AutoFixInterruptedDpkg.*;/Unattended-Upgrade::AutoFixInterruptedDpkg "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::Remove-Unused-Kernel-Packages.*;/Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::Remove-Unused-Dependencies.*;/Unattended-Upgrade::Remove-Unused-Dependencies "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::Remove-New-Unused-Dependencies.*;/Unattended-Upgrade::Remove-New-Unused-Dependencies "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::Automatic-Reboot[^-].*;/Unattended-Upgrade::Automatic-Reboot "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::Automatic-Reboot-Time.*;/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::SyslogEnable.*;/Unattended-Upgrade::SyslogEnable "true";/' "$CONFIG_AUTOUPDATE"
sed -i -e 's/\/\/.*Unattended-Upgrade::SyslogFacility.*;/Unattended-Upgrade::SyslogFacility "upgrade";/' "$CONFIG_AUTOUPDATE"
echo "Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}ESM:${distro_codename}";
};
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";" > /etc/apt/apt.conf.d/50unattended-upgrades
sudo apt install glibc-source -y
systemctl restart unattended-upgrades.service
apt install unattended-upgrades -y
USERCONF='/etc/systemd/user.conf'
SYSTEMCONF='/etc/systemd/system.conf'
sed -i 's/^#DumpCore=.*/DumpCore=no/' "$SYSTEMCONF"
sed -i 's/^#CrashShell=.*/CrashShell=no/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' "$USERCONF"
sed -i 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' "$USERCONF"
sed -i 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' "$USERCONF"
systemctl daemon-reload

if ! grep '^Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/* ; then
  echo 'Acquire::http::AllowRedirect "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*Acquire::http::AllowRedirect*/Acquire::http::AllowRedirect "false";/g' "$(grep -l 'Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/* ; then
  echo 'APT::Get::AllowUnauthenticated "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*APT::Get::AllowUnauthenticated.*/APT::Get::AllowUnauthenticated "false";/g' "$(grep -l 'APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/*; then
  echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/10periodic
else
  sed -i 's/.*APT::Periodic::AutocleanInterval.*/APT::Periodic::AutocleanInterval "7";/g' "$(grep -l 'APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Install-Recommends' /etc/apt/apt.conf.d/*; then
  echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*APT::Install-Recommends.*/APT::Install-Recommends "false";/g' "$(grep -l 'APT::Install-Recommends' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*; then
  echo 'APT::Get::AutomaticRemove "true";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*APT::Get::AutomaticRemove.*/APT::Get::AutomaticRemove "true";/g' "$(grep -l 'APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Install-Suggests' /etc/apt/apt.conf.d/*; then
  echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*APT::Install-Suggests.*/APT::Install-Suggests "false";/g' "$(grep -l 'APT::Install-Suggests' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*; then
  echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
else
  sed -i 's/.*Unattended-Upgrade::Remove-Unused-Dependencies.*/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' "$(grep -l 'Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^Acquire::AllowDowngradeToInsecureRepositories' /etc/apt/apt.conf.d/*; then
  echo 'Acquire::AllowDowngradeToInsecureRepositories "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*Acquire::AllowDowngradeToInsecureRepositories.*/Acquire::AllowDowngradeToInsecureRepositories "false";/g' "$(grep -l 'Acquire::AllowDowngradeToInsecureRepositories' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^Acquire::AllowInsecureRepositories' /etc/apt/apt.conf.d/*; then
  echo 'Acquire::AllowInsecureRepositories "false";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*Acquire::AllowInsecureRepositories.*/Acquire::AllowInsecureRepositories "false";/g' "$(grep -l 'Acquire::AllowInsecureRepositories' /etc/apt/apt.conf.d/*)"
fi

if ! grep '^APT::Sandbox::Seccomp' /etc/apt/apt.conf.d/*; then
  echo 'APT::Sandbox::Seccomp "1";' >> /etc/apt/apt.conf.d/98-hardening-ubuntu
else
  sed -i 's/.*APT::Sandbox::Seccomp.*/APT::Sandbox::Seccomp "1";/g' "$(grep -l 'APT::Sandbox::Seccomp' /etc/apt/apt.conf.d/*)"
fi
#if ! grep 'mount.* /tmp' /etc/apt/apt.conf.d/* ; then
#  echo 'DPkg::Pre-Invoke {"mount -o remount,exec,nodev,nosuid /tmp";};' >> /etc/apt/apt.conf.d/99noexec-tmp
#  echo 'DPkg::Post-Invoke {"mount -o remount,mode=1777,strictatime,noexec,nodev,nosuid /tmp";};' >> /etc/apt/apt.conf.d/99noexec-tmp
#fi
cd ~
#mv ~/pre-configured-files/ubu20/sources.list /etc/apt/sources.list

rm /etc/apt/apt.conf.d/20auto-upgrades
touch /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Update-Package-Lists "1";" >> /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Download-Upgradeable-Packages "1";" >> /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::AutocleanInterval "7";" >> /etc/apt/apt.conf.d/20auto-upgrades
echo "APT::Periodic::Unattended-Upgrade "1";" >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Verbose "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
apt install --reinstall firefox -y
sudo apt install gnupg2
apt-get install libc6 -y
apt install --reinstall sudo -y
apt install --reinstall bash -y
sudo apt-get --purge --reinstall install firefox -y
apt-get update -y && apt install linux-image-generic -y
apt-get update -y && apt-get install linux-headers-generic -y
sudo apt update && apt upgrade -y
#sudo apt -V -y install --reinstall coreutils
apt install e2fsprogs
#sudo apt-get install --only-upgrade bash
apt install software-properties-common -y
#apt-add-repository --yes --update ppa:ansible/ansible
apt-get autoclean -y
#apt-get upgrade libreoffice -y
#apt-get check
touch upgradeablepkgs.txt
apt list --upgradeable >> upgradeablepkgs.txt
touch aptkeylist.txt
apt-key list >> aptkeylist.txt
clear
echo "System fully updated. Please configure update settings." >> ~/script.log
