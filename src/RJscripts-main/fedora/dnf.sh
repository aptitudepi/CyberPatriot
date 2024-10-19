#!/bin/bash

# Configure DNF to check for updates automatically
chattr -i /etc/dnf/dnf.conf
chmod 600 /etc/dnf/dnf.conf
rm /etc/dnf/dnf.conf
touch /etc/dnf/dnf.conf
echo "[main]" >> /etc/dnf/dnf.conf
echo "gpgcheck=True" >> /etc/dnf/dnf.conf
echo "installonly_limit=3" >> /etc/dnf/dnf.conf
echo "clean_requirements_on_remove=True" >> /etc/dnf/dnf.conf
echo "best=False" >> /etc/dnf/dnf.conf
echo "skip_if_unavailable=True" >> /etc/dnf/dnf.conf
echo 'update_cmd = security' >> /etc/dnf/dnf.conf
echo 'apply_updates = yes' >> /etc/dnf/dnf.conf
echo "localpkg_gpgcheck=1" >> /etc/dnf/dnf.conf
# Configure DNF to exclude packages with known vulnerabilities
echo 'fastestmirror=True' >> /etc/dnf/dnf.conf

#Install aide package
sudo dnf install -y aide

# Schedule regular update and vulnerability scans
echo "0 5 * * * /usr/bin/dnf update -y --security" | sudo tee -a /etc/cron.daily/dnf-update.cron
echo "0 5 * * 6 /usr/sbin/aide --check" | sudo tee -a /etc/cron.weekly/aide-scan.cron

# Enable the auditd service
sudo systemctl enable auditd
sudo systemctl start auditd
