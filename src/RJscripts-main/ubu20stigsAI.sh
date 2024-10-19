#!/bin/bash

# Update the package manager cache
apt-get update

# Install the required packages for hardening the system
apt-get install -y fail2ban ufw aide apparmor

# Enable the firewall and allow ssh connections
ufw enable
ufw allow ssh

# Configure Fail2Ban to ban IP addresses that have attempted to login unsuccessfully
echo "
[DEFAULT]
# Ban hosts for one hour
bantime = 3600

# Override /etc/fail2ban/jail.d/00-firewalld.conf
banaction = ufw

[sshd]
enabled = true
" > /etc/fail2ban/jail.local

# Restart Fail2Ban to apply the changes
systemctl restart fail2ban

# Set the permissions on the system boot files to read-only
chmod 0644 /boot/vmlinuz*

# Set the permissions on the system logs to read-only
chmod -R 0644 /var/log/*

# Set the permissions on the Apache logs to read-only
chmod -R 0644 /var/log/apache2/*

# Set the permissions on the PHP logs to read-only
chmod -R 0644 /var/log/php/*

# Set the permissions on the system cron files to read-only
chmod 0644 /etc/cron.d/*
chmod 0644 /etc/crontab
chmod 0644 /etc/cron.hourly/*
chmod 0644 /etc/cron.daily/*
chmod 0644 /etc/cron.weekly/*
chmod 0644 /etc/cron.monthly/*

# Set the permissions on the system network configuration files to read-only
chmod 0644 /etc/sysconfig/network-scripts/ifcfg-*

# Set the permissions on the system SSH configuration file to read-only
chmod 0644 /etc/ssh/sshd_config

# Set the permissions on the system sudoers file to read-only
chmod 0440 /etc/sudoers

# Set the permissions on the system ufw configuration file to read-only
chmod 0644 /etc/ufw/*.rules

# Set the permissions on the system AppArmor configuration files to read-only
chmod 0644 /etc/apparmor/*.d/*

# Enable AppArmor
systemctl enable apparmor
systemctl start apparmor

# Run AIDE to create an initial database of system file hashes
aide --init

# Update the AIDE configuration file to include additional directories and files
echo "
# Include additional directories and files
/etc/ssh/ssh_host_dsa_key
/etc/ssh/ssh_host_dsa_key.pub
/etc/ssh/ssh_host_ecdsa_key
/etc/ssh/ssh_host_ecdsa_key.pub
/etc/ssh/ssh_host_ed25519_key
/etc/ssh/ssh_host_ed25519_key.pub
/etc/ssh/ssh_host_rsa_key
/etc/ssh/ssh_host_rsa_key.pub
/etc/ssl/private/
/etc/ssl/certs/
/var/
" > >> /etc/aide/aide.conf
aide --update
chmod 0644 /etc/aide/aide.conf
chmod 0644 /var/lib/aide/aide.db.gz
chmod 0644 /etc/bashrc
chmod 0644 /etc/profile
chmod 0644 /etc/environment
chmod 0644 /etc/modules
chmod 0644 /etc/sudoers.d/*
chmod -R 0644 /etc/systemd/system/.service
chmod -R 0644 /etc/systemd/system/.target
chmod 0644 /etc/timezone
chmod 0644 /etc/resolv.conf
chmod 0644 /etc/nsswitch.conf
chmod -R 0644 /etc/pam.d/*
chmod 0644 /etc/sysctl.conf
chmod -R 0644 /etc/modules-load.d/*
chmod -R 0644 /etc/default/*
chmod -R 0644 /etc/security/*
chmod -R 0644 /etc/sysctl.d/*
chmod -R 0644 /etc/ssh/*
chmod 0644 /etc/cron.allow
chmod 0644 /etc/cron.deny
chmod -R 0644 /etc/logrotate.d/*
chmod 0644 /etc/ntp.conf
chmod 0644 /etc/chrony.conf
chmod 0644 /etc/logrotate.conf






















