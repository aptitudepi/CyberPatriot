#!/bin/bash

# Update and install necessary packages
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
apt-get install ufw clamtk libpam-cracklib auditd bum chkrootkit rkhunter mod_security -y

# Run AuthCheck.py to generate user and service lists
python3 AuthCheck.py

# Firewall setup
ufw enable
ufw status

# SSH configurations
if grep -q "^ssh$" critical_services.txt; then
    if grep -qF 'PermitRootLogin' /etc/ssh/sshd_config; then
        sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    else
        echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
    fi

    sed -i '/ChallengeResponseAuthentication/d;/PasswordAuthentication/d;/UsePAM/d;/PermitEmptyPasswords/d' /etc/ssh/sshd_config
    echo -e "ChallengeResponseAuthentication no\nPasswordAuthentication no\nUsePAM no\nPermitEmptyPasswords no\nClientAliveInterval 300\nClientAliveCountMax 0\nIgnoreRhosts yes" >> /etc/ssh/sshd_config
    systemctl restart sshd
else
    systemctl stop sshd
    systemctl disable sshd
    apt-get remove -y openssh-server
fi

# Apache configurations
if grep -q "^apache2$" critical_services.txt; then
    echo -e "\n# Apache configurations\nServerSignature Off\nServerTokens Prod\n" >> /etc/apache2/apache2.conf
    systemctl restart apache2
else
    systemctl stop apache2
    systemctl disable apache2
    apt-get remove -y apache2
fi

# MySQL configurations
if grep -q "^mysql$" critical_services.txt; then
    echo -e "\n# MySQL configurations\n[mysqld]\nbind-address = 127.0.0.1\nlocal-infile=0\n" >> /etc/mysql/my.cnf
    mysql_secure_installation
else
    systemctl stop mysql
    systemctl disable mysql
    apt-get remove -y mysql-server
fi

# PHP configurations
if grep -q "^php$" critical_services.txt; then
    sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.*/apache2/php.ini
    sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php/7.*/apache2/php.ini
    sed -i 's/allow_url_include = On/allow_url_include = Off/' /etc/php/7.*/apache2/php.ini
    echo 'disable_functions = exec,shell_exec,passthru,system,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source,proc_open,pcntl_exec' >> /etc/php/7.*/apache2/php.ini
    systemctl restart apache2
else
    apt-get remove -y php*
fi

# Disable root user login
passwd -l root

# Password policies
sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs
sed -i 's/\(pam_unix\.so.*\)$/\1 remember=5 minlen=8/' /etc/pam.d/common-password
sed -i 's/\(pam_cracklib\.so.*\)$/\1 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password

# Configure auditing
auditctl -e 1

# Set home directory permissions
for i in $(mawk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd); do
    [ -d /home/${i} ] && chmod -R 750 /home/${i}
done

# Kernel hardening
cat << EOF > /etc/sysctl.conf
kernel.exec-shield=1
kernel.randomize_va_space=1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5
net.ipv4.ip_forward=0
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.icmp_echo_ignore_all = 1
EOF

sysctl -p

# Prevent IP spoofing
if grep -qF 'multi on' /etc/host.conf; then
    sed -i 's/multi/nospoof/' /etc/host.conf
else
    echo 'nospoof on' >> /etc/host.conf
fi

# Disable USB and Firewire/Thunderbolt
echo 'install usb-storage /bin/true' >> /etc/modprobe.d/disable-usb-storage.conf
echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf

# Check for rootkits and other malicious files
chkrootkit
rkhunter --update && rkhunter --check

# User and admin management
function user_exists() {
    id "$1" &>/dev/null
}

# Check for unauthorized users
while IFS= read -r user
do
    if user_exists "$user"; then
        if ! grep -q "^$user$" all_users.txt; then
            read -p "User $user is not authorized. Delete? (Y/N): " choice
            if [[ $choice == [Yy]* ]]; then
                userdel -r "$user"
                echo "User $user has been deleted."
            fi
        fi
    fi
done < <(cut -d: -f1 /etc/passwd)

# Check for unauthorized admins
while IFS= read -r user
do
    if user_exists "$user"; then
        if grep -q "^$user$" all_users.txt && ! grep -q "^$user$" admin_users.txt; then
            if groups "$user" | grep -q "\bsudo\b"; then
                read -p "User $user is authorized but should not be an admin. Remove admin privileges? (Y/N): " choice
                if [[ $choice == [Yy]* ]]; then
                    deluser "$user" sudo
                    echo "Admin privileges removed from $user."
                fi
            fi
        fi
    fi
done < <(cut -d: -f1 /etc/passwd)

echo "System hardening, configuration, and service management completed successfully."
