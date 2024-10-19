#!/bin/bash
cd ~
mkdir cis
cd cis

#grub
echo "Ensure that this is set under GRUB_CMDLINE_LINUX in /etc/default/grub:\naudit_backlog_limit=8192" > ~/cis/grub_audit_backlog_limit.txt
# Set the default boot entry to the first one
echo "GRUB_DEFAULT=0" >> /etc/default/grub
# Set the timeout for the boot menu
echo "GRUB_TIMEOUT=1" >> /etc/default/grub
# Do not display the boot menu
echo "GRUB_HIDDEN_TIMEOUT=0" >> /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" >> /etc/default/grub
# Disable the ability to boot from external devices
echo "GRUB_DISABLE_LINUX_UUID=true" >> /etc/default/grub
echo "GRUB_DISABLE_RECOVERY=true" >> /etc/default/grub
# Set the boot security level to "high"
echo "GRUB_RECORDFAIL_TIMEOUT=0" >> /etc/default/grub
echo "GRUB_TIMEOUT_STYLE=hidden" >> /etc/default/grub
# Enable SELinux support in the boot menu
echo "GRUB_CMDLINE_LINUX="selinux=1"" >> /etc/default/grub
# Set the kernel command-line arguments to enforce boot integrity and enable kernel module loading restrictions
echo "GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX integrity=%LABEL:integrity% load_module_blacklist=%LABEL:module_blacklist% load_module_whitelist=%LABEL:module_whitelist%"" >> /etc/default/grub
