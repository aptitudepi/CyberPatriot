#!/bin/bash

sudo apt install auditd -y
chmod 777 /etc/audit/auditd.conf
chattr -i /etc/audit/auditd.conf
sudo sed 's/log_file = .*/log_file = /var/log/audit/audit.log/g' /etc/audit/auditd.conf
sudo sed 's/log_format = .*/log_format = RAW/g' /etc/audit/auditd.conf
sudo sed 's/log_group = .*/log_group = root/g' /etc/audit/auditd.conf
sudo sed 's/##tcp_listen_port = .*/##tcp_listen_port = /g' /etc/audit/auditd.conf
sudo sed 's/tcp_listen_queue = .*/tcp_listen_queue = 5/g' /etc/audit/auditd.conf
sudo sed 's/priority_boost = .*/priority_boost = 4/g' /etc/audit/auditd.conf
sudo sed 's/flush = .*/flush = INCREMENTAL/g' /etc/audit/auditd.conf
sudo sed 's/tcp_client_max_idle = .*/tcp_client_max_idle = 0/g' /etc/audit/auditd.conf
sudo sed 's/enable_krb5 = .*/enable_krb5 = no/g' /etc/audit/auditd.conf
sudo sed 's/krb5_principal = .*/krb5_princiapl = auditd/g' /etc/audit/auditd.conf
sudo sed 's/##krb5_key_file = .*/##krb5_key_file = /etc/audit/audit.key/g' /etc/audit/auditd.conf
sudo sed 's/freq = .*/freq = 20/g' /etc/audit/auditd.conf
sudo sed 's/num_logs = .*/num_logs = 4/g' /etc/audit/auditd.conf
sudo sed 's/disp_qos = .*/disp_qos = lossy/g' /etc/audit/auditd.conf
sudo sed 's/space_left = .*/space_left = 75/g' /etc/audit/auditd.conf
sudo sed 's/space_left_action = .*/space_left_action = SYSLOG/g' /etc/audit/auditd.conf
sudo sed 's/action_mail_acct = .*/action_mail_acct = root/g' /etc/audit/auditd.conf
sudo sed 's/admin_space_left = .*/admin_space_left = 50/g' /etc/audit/auditd.conf
sudo sed 's/dispatcher = .*/dispatcher = /sbin/audispd/g' /etc/audit/auditd.conf
sudo sed 's/name_format = .*/name_format = NONE/g' /etc/audit/auditd.conf
sudo sed 's/##name = .*/##name = mydomain/g' /etc/audit/auditd.conf
sudo sed 's/max_log_file = .*/max_log_file = 5/g' /etc/audit/auditd.conf
sudo sed 's/max_log_file_action = .*/max_log_file_action = ROTATE/g' /etc/audit/auditd.conf
sudo sed 's/admin_space_left_action = .*/admin_space_left_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/disk_full_action = .*/disk_full_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/disk_error_action = .*/disk_error_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/tcp_max_per_addr = .*/tcp_max_per_addr = 1/g' /etc/audit/auditd.conf
sudo sed 's/##tcp_client_ports = .*/##tcp_client_ports = 1024-65535/g' /etc/audit/auditd.conf
echo '#
# This file controls the configuration of the audit daemon
#
local_events = yes
log_file = /var/log/audit/audit.log
write_logs = yes
log_format = RAW
log_group = root
priority_boost = 4
flush = INCREMENTAL_ASYNC
##freq = 20
num_logs = 5
disp_qos = lossy
dispatcher = /sbin/audispd
name_format = NONE
##name = mydomain
max_log_file = 6
max_log_file_action = ROTATE
space_left = 75
space_left_action = SYSLOG
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
##tcp_listen_port =
tcp_listen_queue = 5
tcp_max_per_addr = 1
##tcp_client_ports = 1024-65535
tcp_client_max_idle = 0
enable_krb5 = no
krb5_principal = auditd
##krb5_key_file = /etc/audit/audit.key' >> /etc/audit/auditd.conf
chmod 644 /etc/audit/auditd.conf
sudo mv ~/pre-configured-files/audit.rules /etc/audit/audit.rules
AUDITDCONF='/etc/audit/auditd.conf'
AUDITRULES='/etc/audit/rules.d/hardening.rules'
DEFAULTGRUB='/etc/default/grub.d'
AUDITD_RULES='./misc/audit-base.rules ./misc/audit-aggressive.rules ./misc/audit-docker.rules'
AUDITD_MODE='1'
sed -i 's/^action_mail_acct =.*/action_mail_acct = root/' "$AUDITDCONF"
sed -i 's/^admin_space_left_action = .*/admin_space_left_action = halt/' "$AUDITDCONF"
sed -i 's/^max_log_file_action =.*/max_log_file_action = keep_logs/' "$AUDITDCONF"
sed -i 's/^space_left_action =.*/space_left_action = email/' "$AUDITDCONF"

if ! grep -q 'audit=1' /proc/cmdline; then
  echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX audit=1 audit_backlog_limit=8192\"" > "$DEFAULTGRUB/99-hardening-audit.cfg"
fi

cp "./misc/audit.header" /etc/audit/audit.rules
  for l in $AUDITD_RULES; do
    cat "$l" >> /etc/audit/audit.rules
  done
  cat "./misc/audit.footer" >> /etc/audit/audit.rules

sed -i "s/-f.*/-f $AUDITD_MODE/g" /etc/audit/audit.rules

cp /etc/audit/audit.rules "$AUDITRULES"

systemctl enable auditd
systemctl restart auditd.service

if [[ $VERBOSE == "Y" ]]; then
  systemctl status auditd.service --no-pager
  echo
fi
echo "auditd configured, pls reboot" >> ~/script.log
#chattr +i /etc/audit/audit.rules
