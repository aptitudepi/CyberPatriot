
# Update system packages
dnf update -y

# Set password policies
authconfig --passminlen=14 --passmaxrepeat=3 --passminage=30 --passmaxage=90 --update

# Disable remote root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl reload sshd

# Set permissions for user home directories
chmod 0750 /home/*

# Enable firewall
systemctl enable firewalld
systemctl start firewalld

# Set firewall rules
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Set SELinux to enforcing mode
sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
setenforce enforcing

# Set noexec on /tmp partition
echo "tmpfs /tmp tmpfs nosuid,nodev,noexec 0 0" >> /etc/fstab
mount -o remount /tmp

# Set noexec on /var/tmp partition
echo "tmpfs /var/tmp tmpfs nosuid,nodev,noexec 0 0" >> /etc/fstab
mount -o remount /var/tmp

# Install auditing tool
dnf install audit -y

# Enable auditing
sed -i 's/^#max_log_file_action = keep_logs/max_log_file_action = rotate/' /etc/audit/auditd.conf
systemctl enable auditd
systemctl start auditd

# Configure logrotate
echo "
/var/log/audit/audit.log {
  missingok
  notifempty
  compress
  size=100M
  create 0640 root root
  sharedscripts
  postrotate
    /usr/libexec/augenrules --load
  endscript
}
" > /etc/logrotate.d/audit

# Install AIDE
dnf install aide -y

# Initialize AIDE database
aide --init

# Copy AIDE configuration file
cp /etc/aide.conf /etc/aide.conf.bak

# Update AIDE configuration file
sed -i 's/^#NORMAL$/NORMAL/' /etc/aide.conf
sed -i 's/^#NORMAL$/NORMAL/' /etc/aide.conf

# Create daily cron job for AIDE
echo "0 5 * * * root /usr/sbin/aide --check" >> /etc/crontab
