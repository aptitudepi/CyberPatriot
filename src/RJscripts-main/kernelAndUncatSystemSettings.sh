#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "confidentiality" > /sys/kernel/security/lockdown
echo "integrity" > /sys/kernel/security/lockdown
touch /etc/selinux/config
echo "SELINUX=enforcing" > /etc/selinux/config
# Backup the original kernel configuration file
cp /boot/config-$(uname -r) /boot/config-$(uname -r).bak

# Enable security options in the kernel configuration
echo "Hardening the Linux kernel..."

# Enable Secure Computing Mode (SECCOMP)
echo "CONFIG_SECCOMP=y" >> /boot/config-$(uname -r)

# Enable Address Space Layout Randomization (ASLR)
echo "CONFIG_RANDOMIZE_BASE=y" >> /boot/config-$(uname -r)

# Enable Kernel Address Space Layout Randomization (KASLR)
echo "CONFIG_RANDOMIZE_MEMORY=y" >> /boot/config-$(uname -r)

# Enable Control Group (CGROUP) support
echo "CONFIG_CGROUPS=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_CPUACCT=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_DEVICE=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_FREEZER=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_SCHED=y" >> /boot/config-$(uname -r)
echo "CONFIG_CPUSETS=y" >> /boot/config-$(uname -r)
echo "CONFIG_PROC_PID_CPUSET=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_CPUACCT=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_DEVICE=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_FREEZER=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_SCHED=y" >> /boot/config-$(uname -r)
echo "CONFIG_CPUSETS=y" >> /boot/config-$(uname -r)
echo "CONFIG_PROC_PID_CPUSET=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_CPUACCT=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_DEVICE=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_FREEZER=y" >> /boot/config-$(uname -r)
echo "CONFIG_CGROUP_SCHED=y" >> /boot/config-$(uname -r)
echo "CONFIG_CPUSETS=y" >> /boot/config-$(uname -r)
echo "CONFIG_PROC_PID_CPUSET=y" >> /boot/config-$(uname -r)

# Enable hardened usercopy protection
echo "CONFIG_HARDENED_USERCOPY=y" >> /boot/config-$(uname -r)

# Enable Kernel Page Table Isolation (KPTI)
echo "CONFIG_PAGE_TABLE_ISOLATION=y" >> /boot/config-$(uname -r)

# Enable Secure Memory Encryption (SME)
echo "CONFIG_CRYPTO_DEV_SP_PSP=y" >> /boot/config-$(uname -r)
echo "CONFIG_CRYPTO_DEV_SP_CCP=y" >> /boot/config-$(uname -r)

# Enable other security features (optional)
echo "CONFIG_SECURITY=y" >> /boot/config-$(uname -r)
echo "CONFIG_SECURITYFS=y" >> /boot/config-$(uname -r)
echo "CONFIG_SECURITY_NETWORK=y" >> /boot/config-$(uname -r)

# Recompile and install the hardened kernel
echo "Recompiling and installing the hardened kernel..."

aptinstall build-essential -y
apt-get source linux-image-$(uname -r)
apt-get build-dep linux-image-$(uname -r)
cd linux-*
cp /boot/config-$(uname -r) .config
make olddefconfig
make -j$(nproc)
make modules_install
make install

# Update GRUB configuration
update-grub

echo "Kernel hardening completed successfully. Please reboot your system to apply the changes."
