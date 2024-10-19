#auditing files
apt-get -y -qq install auditd audispd-plugins 
auditctl -e 1
auditctl -a exit,always -F arch=b64 -F euid=0 -S execve -k rootcmd
auditctl -a exit,always -F arch=b32 -F euid=0 -S execve -k rootcmd
sed -i 's/^active.*/active = yes/g' /etc/audisp/plugins.d/syslog.conf
service auditd start
echo "Audit service has been installed and started." >> ~/script.log
"""
sudo apt install auditd audispd-plugins -y
for x in `ls /etc`
do
  sudo service auditd stop
  sudo auditctl -w /etc/$x -p rwxa
  sudo echo -w /etc/$x -p rwxa >> /etc/audit/audit.rules
  echo auditctl -w /etc/$x -p rwxa >> auditcommands.txt
  sudo service auditd start
done 
sudo service auditd stop
auditctl -e 1
auditctl -a exit,always -F arch=b64 -F euid=0 -S execve -k rootcmd
auditctl -a exit,always -F arch=b32 -F euid=0 -S execve -k rootcmd
sed -i 's/^active.*/active = yes/g' /etc/audisp/plugins.d/syslog.conf
service auditd start
echo "Audit service installed and started." >> ~/script.log

#more auditd stuff
sed -i 's/^action_mail_acct.*/action_mail_acct=root/' /etc/audit/auditd.conf || echo 'action_mail_acct=root' >> /etc/audit/auditd.conf
sed -i 's/^admin_space_left_action.*/admin_space_left_action=halt/' /etc/audit/auditd.conf || echo 'admin_space_left_action=halt' >> /etc/audit/auditd.conf
sed -i 's/^max_log_file.*/max_log_file=10/' /etc/audit/auditd.conf || echo 'max_log_file=10' >> /etc/audit/auditd.conf
sed -i 's/^max_log_file_action.*/max_log_file_action=keep_logs/' /etc/audit/auditd.conf || echo 'max_log_file_action=keep_logs' >> /etc/audit/auditd.conf
sed -i 's/^space_left_action.*/space_left_action=email/' /etc/audit/auditd.conf || echo 'space_left_action=email' >> /etc/audit/auditd.conf
sed -i 's/^GRUB_CMDLINE_LINUX.*/GRUB_CMDLINE_LINUX="audit=1"/' /etc/default/grub|| echo 'GRUB_CMDLINE_LINUX="audit=1"' >> /etc/default/grub
echo "check_signatures=enforce" >> /etc/grub.d/40_custom_configs
echo "superusers='root'" >> /etc/grub.d/40_custom_configs
echo "password_pbkdf2 root root" >> /etc/grub.d/40_custom_configs
update-grub
echo "-a exit,always -F arch=b32 -S sethostname -S setdomainname -k system-locale"  >> /etc/audit/audit.rules
echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/network -p wa -k system-locale" >> /etc/audit/audit.rules
echo "-w /etc/group -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/audit.rules
sudo sed 's/log_file = .*/log_file = /var/log/audit/audit.log/g' /etc/audit/auditd.conf
sudo sed 's/log_format = .*/log_format = RAW/g' /etc/audit/auditd.conf
sudo sed 's/log_group = .*/log_group = root/g' /etc/audit/auditd.conf
sudo sed 's/priority_boost = .*/priority_boost = 4/g' /etc/audit/auditd.conf
sudo sed 's/flush = .*/flush = INCREMENTAL/g' /etc/audit/auditd.conf
sudo sed 's/freq = .*/freq = 20/g' /etc/audit/auditd.conf
sudo sed 's/num_logs = .*/num_logs = 4/g' /etc/audit/auditd.conf
sudo sed 's/disp_qos = .*/disp_qos = lossy/g' /etc/audit/auditd.conf
sudo sed 's/dispatcher = .*/dispatcher = /sbin/audispd/g' /etc/audit/auditd.conf
sudo sed 's/name_format = .*/name_format = NONE/g' /etc/audit/auditd.conf
sudo sed 's/##name = .*/##name = mydomain/g' /etc/audit/auditd.conf
sudo sed 's/max_log_file = .*/max_log_file = 5/g' /etc/audit/auditd.conf
sudo sed 's/max_log_file_action = .*/max_log_file_action = ROTATE/g' /etc/audit/auditd.conf
sudo sed 's/space_left = .*/space_left = 75/g' /etc/audit/auditd.conf
sudo sed 's/space_left_action = .*/space_left_action = SYSLOG/g' /etc/audit/auditd.conf
sudo sed 's/action_mail_acct = .*/action_mail_acct = root/g' /etc/audit/auditd.conf
sudo sed 's/admin_space_left = .*/admin_space_left = 50/g' /etc/audit/auditd.conf
sudo sed 's/admin_space_left_action = .*/admin_space_left_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/disk_full_action = .*/disk_full_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/disk_error_action = .*/disk_error_action = SUSPEND/g' /etc/audit/auditd.conf
sudo sed 's/##tcp_listen_port = .*/##tcp_listen_port = /g' /etc/audit/auditd.conf
sudo sed 's/tcp_listen_queue = .*/tcp_listen_queue = 5/g' /etc/audit/auditd.conf
sudo sed 's/tcp_max_per_addr = .*/tcp_max_per_addr = 1/g' /etc/audit/auditd.conf
sudo sed 's/##tcp_client_ports = .*/##tcp_client_ports = 1024-65535/g' /etc/audit/auditd.conf
sudo sed 's/tcp_client_max_idle = .*/tcp_client_max_idle = 0/g' /etc/audit/auditd.conf
sudo sed 's/enable_krb5 = .*/enable_krb5 = no/g' /etc/audit/auditd.conf
sudo sed 's/krb5_principal = .*/krb5_princiapl = auditd/g' /etc/audit/auditd.conf
sudo sed 's/##krb5_key_file = .*/##krb5_key_file = /etc/audit/audit.key/g' /etc/audit/auditd.conf
systemctl enable rsyslog
auditctl -e 1
#sudo service auditd start
#sudo service auditd restart
clear
echo "auditd configured and rc.local is secured" >> ~/script.log
"""

#php configs
#add php7.0 stuff
"""
echo -n "Should PHP be on this system? [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  apt-get install php5-suhosin -y
  sed -i 's/^safe_mode.*/safe_mode = On/' /etc/php5/apache2/php.ini || echo 'safe_mode = On' >> /etc/php5/apache2/php.ini
  sed -i 's/^safe_mode_gid.*/safe_mode_gid = On/' /etc/php5/apache2/php.ini || echo 'safe_mode_gid = On' >> /etc/php5/apache2/php.ini
  sed -i 's/^register_globals.*/register_globals = Off/' /etc/php5/apache2/php.ini || echo 'register_globals = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^expose_php.*/expose_php = Off/' /etc/php5/apache2/php.ini || echo 'expose_php = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^track_errors.*/track_errors = Off/' /etc/php5/apache2/php.ini || echo 'track_errors = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^html_errors.*/html_errors = Off/' /etc/php5/apache2/php.ini || echo 'html_errors = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^display_errors.*/display_errors = Off/' /etc/php5/apache2/php.ini || echo 'display_errors = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^allow_url_fopen.*/allow_url_fopen = Off/' /etc/php5/apache2/php.ini || echo 'allow_url_fopen = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^disable_functions.*/disable_functions = php_uname, getmyuid, getmypid, passthru, leak, listen, diskfreespace, tmpfile, link, ignore_user_abord, shell_exec, dl, set_time_limit, exec, system, highlight_file, source, show_source, fpaththru, virtual, posix_ctermid, posix_getcwd, posix_getegid, posix_geteuid, posix_getgid, posix_getgrgid, posix_getgrnam, posix_getgroups, posix_getlogin, posix_getpgid, posix_getpgrp, posix_getpid, posix, _getppid, posix_getpwnam, posix_getpwuid, posix_getrlimit, posix_getsid, posix_getuid, posix_isatty, posix_kill, posix_mkfifo, posix_setegid, posix_seteuid, posix_setgid, posix_setpgid, posix_setsid, posix_setuid, posix_times, posix_ttyname, posix_uname, proc_open, proc_close, proc_get_status, proc_nice, proc_terminate, phpinfo/' /etc/php5/apache2/php.ini || echo 'disable_functions = php_uname, getmyuid, getmypid, passthru, leak, listen, diskfreespace, tmpfile, link, ignore_user_abord, shell_exec, dl, set_time_limit, exec, system, highlight_file, source, show_source, fpaththru, virtual, posix_ctermid, posix_getcwd, posix_getegid, posix_geteuid, posix_getgid, posix_getgrgid, posix_getgrnam, posix_getgroups, posix_getlogin, posix_getpgid, posix_getpgrp, posix_getpid, posix, _getppid, posix_getpwnam, posix_getpwuid, posix_getrlimit, posix_getsid, posix_getuid, posix_isatty, posix_kill, posix_mkfifo, posix_setegid, posix_seteuid, posix_setgid, posix_setpgid, posix_setsid, posix_setuid, posix_times, posix_ttyname, posix_uname, proc_open, proc_close, proc_get_status, proc_nice, proc_terminate, phpinfo' >> /etc/php5/apache2/php.ini
  sed -i 's/^allow_url_include.*/allow_url_include = Off/' /etc/php5/apache2/php.ini || echo 'allow_url_include = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^file_uploads.*/file_uploads = Off/' /etc/php5/apache2/php.ini || echo 'file_uploads = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^upload_max_filesize.*/upload_max_filesize = 2M/' /etc/php5/apache2/php.ini || echo 'upload_max_filesize = 2M' >> /etc/php5/apache2/php.ini
  sed -i 's/^max_execution_time.*/max_execution_time = 10/' /etc/php5/apache2/php.ini || echo 'max_execution_time = 10' >> /etc/php5/apache2/php.ini
  sed -i 's/^max_input_time.*/max_input_time = 30/' /etc/php5/apache2/php.ini || echo 'max_input_time = 30' >> /etc/php5/apache2/php.ini
  sed -i 's/^memory_limit.*/memory_limit = 40M/' /etc/php5/apache2/php.ini || echo 'memory_limit = 40M' >> /etc/php5/apache2/php.ini
  sed -i 's/^post_max_size.*/post_max_size=1K/' /etc/php5/apache2/php.ini || echo 'post_max_size=1K' >> /etc/php5/apache2/php.ini
  sed -i 's/^session.cookie_httponly.*/session.cookie_httponly = 1/' /etc/php5/apache2/php.ini || echo 'session.cookie_httponly = 1' >> /etc/php5/apache2/php.ini
  sed -i 's/^magic_quotes_gpc.*/magic_quotes_gpc = Off/' /etc/php5/apache2/php.ini || echo 'magic_quotes_gpc = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^extension.*/extension=suhosin.so/' /etc/php5/apache2/php.ini || echo 'extension=sudosin.so' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.session.encrypt.*/suhosin.session.encrypt = Off/' /etc/php5/apache2/php.ini || echo 'suhosin.session.encrypt = Off' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.log.syslog.*/suhosin.log.syslog/' /etc/php5/apache2/php.ini || echo 'suhosin.log.syslog=511' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.executor.include.mix_traversal.*/suhosin.executor.include.mix_traversal=4/' /etc/php5/apache2/php.ini || echo 'suhosin.executor.include.mix_traversal=4' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.executor.disable_eval.*/suhosin.executor.disable_eval=On/' /etc/php5/apache2/php.ini || echo 'suhosin.executor.disable_eval=On' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.executor.disable_emodifier.*/suhosin.executor.disable_emodifier=On/' /etc/php5/apache2/php.ini || echo 'suhosin.executor.disable_emodifier=On' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.mail.protect.*/suhosin.mail.protect=2/' /etc/php5/apache2/php.ini || echo 'suhosin.mail.protect=2' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.sql.bailout_on_error.*/suhosin.sql.bailout_on_error=On/' /etc/php5/apache2/php.ini || echo 'suhosin.sql.bailout_on_error=On' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.cookie.max_vars.*/suhosin.cookie.max_vars = 2048/' /etc/php5/apache2/php.ini || echo 'suhosin.cookie.max_vars = 2048' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.get.max_array_index_length.*/suhosin.get.max_array_index_length = 256/' /etc/php5/apache2/php.ini || echo 'suhosin.get.max_array_index_length = 256' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.post.max_array_index_length.*/suhosin.post.max_array_index_length = 256/' /etc/php5/apache2/php.ini || echo 'suhosin.post.max_array_index_length = 256' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.post.max_totalname_lengt.*/suhosin.post.max_totalname_length = 8192/' /etc/php5/apache2/php.ini || echo 'suhosin.post.max_totalname_length = 8192' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.post.max_vars.*/suhosin.post.max_vars = 2048/' /etc/php5/apache2/php.ini || echo 'suhosin.post.max_vars = 2048' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.request.max_totalname_length.*/suhosin.request.max_totalname_length = 8192/' /etc/php5/apache2/php.ini || echo 'suhosin.request.max_totalname_length = 8192' >> /etc/php5/apache2/php.ini
  sed -i 's/^suhosin.request.max_varname_length.*/suhosin.request.max_varname_length = 256/' /etc/php5/apache2/php.ini || echo 'suhosin.request.max_varname_length = 256' >> /etc/php5/apache2/php.ini
  clear
  echo "PHP configured. Please delete php5-suhosin if not needed." >> ~/script.log
else
  sudo apt-get autoremove --purge php5-suhosin* -y
"""
