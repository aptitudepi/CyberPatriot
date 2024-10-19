#!/bin/bash

# Initialize the variables
# Our detection counter
detection_counter=0

# Allow for modifications option
allow_modifications=0

# Check the system's integrity
echo "Checking the system's integrity..."
# Check if port 22 is open without using `netstat`
echo "Checking if port 22 is open..."
if [ `ss -an | grep 22 | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPort 22 is open\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Close port 22
        echo "Closing port 22..."
        iptables -A INPUT -p tcp --dport 22 -j DROP
        # Log the fix in green
        echo -e "\e[32mPort 22 is now closed\e[0m"
    fi
fi

# Check if RDP port is open without using `netstat`
echo "Checking if RDP port is open..."
if [ `ss -an | grep 3389 | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mRDP port is open\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Close RDP port
        echo "Closing RDP port..."
        iptables -A INPUT -p tcp --dport 3389 -j DROP
        # Log the fix in green
        echo -e "\e[32mRDP port is now closed\e[0m"
    fi
fi

# Get current distribution name
distro_name=`cat /etc/*-release | grep ^NAME | cut -d "=" -f 2 | sed 's/"//g'`

# Debug distro name
echo "Distro name: $distro_name"

# Define `check_update(cmd)` function
function check_update {
    # Check if there are any updates
    echo "Checking if there are any updates..."
    if [ `$1 | wc -l` -eq 0 ]; then
        # Do nothing
        echo "No updates available"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mUpdates available\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Update the system
            echo "Updating the system..."
            apt update && apt upgrade -y
            # Log the fix in green
            echo -e "\e[32mSystem updated\e[0m"
        fi
    fi
}

# Define `install_package(pkg)` function
function install_package {
    # Check if the package is installed
    echo "Checking if $1 is installed..."
    if [ `dpkg -l | grep $1 | wc -l` -eq 0 ]; then
        # Log the detection in red
        echo -e "\e[31m$1 is not installed\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Install the package
            echo "Installing $1..."
            apt install $1 -y
            # Log the fix in green
            echo -e "\e[32m$1 installed\e[0m"
        fi
    else
        # Do nothing
        echo "$1 is installed"
    fi
}

# Get list of running services
services=`systemctl list-units --type=service --state=running | grep -v "UNIT" | cut -d " " -f 1`

# Check if the distribution is CentOS
if [ $distro_name == "CentOS Linux" ]; then
    # Check if we can do modifications
    if [ $allow_modifications -eq 1 ]; then
        # Delete sources.list and rebuild it
        echo "Rebuilding sources.list..."
        rm /etc/yum.repos.d/*
        echo "[base]" >> /etc/yum.repos.d/base.repo
        echo "name=CentOS-\$releasever - Base" >> /etc/yum.repos.d/base.repo
        echo "baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/" >> /etc/yum.repos.d/base.repo
        echo "gpgcheck=1" >> /etc/yum.repos.d/base.repo
        echo "gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7" >> /etc/yum.repos.d/base.repo
        echo "enabled=1" >> /etc/yum.repos.d/base.repo
    fi
    # Check if the system is up to date
    check_update "yum check-update"
fi

# Check if the distribution is Debian
if [ $distro_name == "Debian GNU/Linux" ]; then
    # Check if we can do modifications
    if [ $allow_modifications -eq 1 ]; then
        # Delete sources.list and rebuild it
        echo "Rebuilding sources.list..."
        rm /etc/apt/sources.list
        echo "deb http://deb.debian.org/debian/ stable main contrib non-free" >> /etc/apt/sources.list
        echo "deb-src http://deb.debian.org/debian/ stable main contrib non-free" >> /etc/apt/sources.list
    fi
    # Check if the system is up to date
    check_update "apt list --upgradable"
fi

# Find all hidden users
echo "Checking for hidden users..."
if [ `cat /etc/passwd | grep -v "/bin/bash" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No hidden users"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mHidden users detected\e[0m"
fi

# Loop through all users
echo "Checking users..."
for user in `cat /etc/passwd | cut -d ":" -f 1`; do
    # Check if the user is root
    if [ $user == "root" ]; then
        # Do nothing
        echo "User $user is root"
    else
        # Check if the user has a password
        # Build test argument
        test_arg=(`cat /etc/shadow | grep $user | cut -d ":" -f 2`);
        # Check if the test argument is empty
        if [ -z $test_arg ]; then
            # Increment detection counter
            detection_counter=$((detection_counter+1))
            # Log the detection in red
            echo -e "\e[31mUser $user has no password\e[0m"
        else
            # Do nothing
            echo "User $user has a password"
        fi
    fi
done

# Ensure netcat connections are closed without using `netstat`
echo "Checking if netcat connections are closed..."
if [ `netstat -an | grep nc | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No netcat connections"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mNetcat connections detected\e[0m"
fi

# Ensure you cannot ssh as root
echo "Checking if you can ssh as root..."
# Build test argument
test_arg=(`cat /etc/ssh/sshd_config | grep PermitRootLogin | cut -d " " -f 2`);
# Check if the test argument is empty
if [ -z $test_arg ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mYou can ssh as root\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable root login
        echo "Disabling root login..."
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config
        # Log the fix in green
        echo -e "\e[32mRoot login disabled\e[0m"
    fi
else
    # Do nothing
    echo "You cannot ssh as root"
fi


# Ensure a default maximum password age is set
# Build test argument
test_arg=(`cat /etc/login.defs | grep PASS_MAX_DAYS | cut -d " " -f 2`);
# Check if the test argument is empty
if [ -z $test_arg ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mA default maximum password age is not set\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set a default maximum password age
        echo "Setting a default maximum password age..."
        echo "PASS_MAX_DAYS 90" >> /etc/login.defs
        # Log the fix in green
        echo -e "\e[32mDefault maximum password age set\e[0m"
    fi
else
    # Do nothing
    echo "A default maximum password age is set"
fi

# Check if a minimum password length is set using /etc/pam.d/
echo "Checking if a minimum password length is set..."
# Build test argument
test_arg=(`cat /etc/pam.d/common-password | grep minlen | cut -d "=" -f 2`);
# Check if the test argument equals 14
if [ "$test_arg" -eq "14" ]; then
    # Do nothing
    echo "A minimum password length is set"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mA minimum password length is not set\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set a minimum password length
        echo "Setting a minimum password length..."
        echo "password requisite pam_cracklib.so minlen=14" >> /etc/pam.d/common-password
        # Log the fix in green
        echo -e "\e[32mMinimum password length set\e[0m"
    fi
fi

# Check what hashing algorithm is used for passwords
echo "Checking what hashing algorithm is used for passwords..."
# Build test argument
test_arg=(`cat /etc/login.defs | grep ENCRYPT_METHOD | cut -d " " -f 2`);
# Test if the test argument equals "SHA512"
if [ $test_arg == "SHA512" ]; then
    # Do nothing
    echo "SHA512 is used for passwords"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSHA512 is not used for passwords\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set SHA512 as the hashing algorithm
        echo "Setting SHA512 as the hashing algorithm..."
        echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
        # Log the fix in green
        echo -e "\e[32mSHA512 is now used for passwords\e[0m"
    fi
fi

# Make sure apache is updated
echo "Checking if apache is updated..."
if [ `apt list --upgradable | grep apache2 | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Apache is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mApache is not updated\e[0m"
fi

# Ensure apache has trace requests disabled
echo "Checking if apache has trace requests disabled..."
# Build test argument
test_arg=(`cat /etc/apache2/apache2.conf | grep TraceEnable | cut -d " " -f 2`);
# Check if the test argument equals "off"
if [ "$test_arg" == "off" ]; then
    # Do nothing
    echo "Apache has trace requests disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mApache has trace requests enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable trace requests
        echo "Disabling trace requests..."
        echo "TraceEnable off" >> /etc/apache2/apache2.conf
        # Log the fix in green
        echo -e "\e[32mTrace requests disabled\e[0m"
    fi
fi

# Check for insecure permissions on PostgreSQL 
echo "Checking for insecure permissions on PostgreSQL..."
if [ `ls -l /etc/postgresql/ | grep -v "drwx------" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No insecure permissions on PostgreSQL"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mInsecure permissions on PostgreSQL detected\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix insecure permissions on PostgreSQL
        echo "Fixing insecure permissions on PostgreSQL..."
        chmod 700 /etc/postgresql/
        # Log the fix in green
        echo -e "\e[32mInsecure permissions on PostgreSQL fixed\e[0m"
    fi
fi

# Check if we have a DNS service installed
echo "Checking if we have a DNS service installed..."
if [ `apt list --installed | grep bind9 | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No DNS service installed"
else
    # Ensure the DNS server is disabled
    echo "Checking if the DNS server is disabled..."
    if [ `systemctl is-enabled bind9 | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "DNS server is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mDNS server is enabled\e[0m"
    fi
fi
# Disable FTP Service if we have one installed
echo "Checking if FTP Service is disabled..."
if [ `apt list --installed | grep vsftpd | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No FTP Service installed"
else
    # Ensure the FTP server is disabled
    echo "Checking if the FTP server is disabled..."
    if [ `systemctl is-enabled vsftpd | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "FTP server is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mFTP server is enabled\e[0m"
    fi
fi

# Enable extra dictionary based password strength checks
echo "Checking if extra dictionary based password strength checks are enabled..."
if [ `cat /etc/pam.d/common-password | grep "pam_cracklib.so" | grep "retry=3" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Extra dictionary based password strength checks are enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mExtra dictionary based password strength checks are not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/pam.d/common-password..."
        cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
        # Fix the issue
        echo "Fixing /etc/pam.d/common-password..."
        sed -i 's/pam_cracklib.so/pam_cracklib.so retry=3/' /etc/pam.d/common-password
    fi
fi

# Check if GECOS password strength checks are enabled
echo "Checking if GECOS password strength checks are enabled..."
if [ `cat /etc/pam.d/common-password | grep "pam_cracklib.so" | grep "gecoscheck=1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "GECOS password strength checks are enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mGECOS password strength checks are not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/pam.d/common-password..."
        cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
        # Fix the issue
        echo "Fixing /etc/pam.d/common-password..."
        sed -i 's/pam_cracklib.so/pam_cracklib.so gecoscheck=1/' /etc/pam.d/common-password
    fi
fi

# Ensure the linux kernel is updated
echo "Checking if the linux kernel is updated..."
if [ `apt list --upgradable | grep linux-image | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Linux kernel is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLinux kernel is not updated\e[0m"
fi

# Ensure NFS service is disabled if we have one installed
echo "Checking if NFS Service is disabled..."
if [ `apt list --installed | grep nfs-kernel-server | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No NFS Service installed"
else
    # Ensure the NFS server is disabled
    echo "Checking if the NFS server is disabled..."
    if [ `systemctl is-enabled nfs-kernel-server | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "NFS server is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mNFS server is enabled\e[0m"
    fi
fi

# Check if OpenSSL shared libraries are updated
echo "Checking if OpenSSL shared libraries are updated..."
if [ `apt list --upgradable | grep libssl | wc -l` -eq 0 ]; then
    # Do nothing
    echo "OpenSSL shared libraries are updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mOpenSSL shared libraries are not updated\e[0m"
fi

# Check if PHP is updated
echo "Checking if PHP is updated..."
if [ `apt list --upgradable | grep php | wc -l` -eq 0 ]; then
    # Do nothing
    echo "PHP is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPHP is not updated\e[0m"
fi

# Check if PHP has trace requests disabled version ambiguous
# Get PHP path
php_path=`which php`
# Check if PHP has trace requests disabled if PHP is installed
if [ `which php | wc -l` -eq 1 ]; then
    if [ `cat $php_path | grep "expose_php = Off" | wc -l` -eq 1 ]; then
        # Do nothing
        echo "PHP has trace requests disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mPHP has trace requests enabled\e[0m"
    fi
else
    # Do nothing
    echo "PHP is not installed"
fi

# Ensure there is restricted access to kernel syslogs
echo "Checking if there is restricted access to kernel syslogs..."
if [ `cat /etc/rsyslog.conf | grep "auth,authpriv.*" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "There is restricted access to kernel syslogs"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mThere is not restricted access to kernel syslogs\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/rsyslog.conf..."
        cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
        # Fix the issue
        echo "Fixing /etc/rsyslog.conf..."
        echo "auth,authpriv.* /var/log/auth.log" >> /etc/rsyslog.conf
    fi
fi

# Ensure root password is not blank
echo "Checking if root password is not blank..."
if [ `cat /etc/shadow | grep "root:" | cut -d ":" -f 2` == "" ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mRoot password is blank\e[0m"
else
    # Do nothing
    echo "Root password is not blank"
fi

# Disable the Samba service if its installed
echo "Checking if Samba service is disabled..."
if [ `which smb | wc -l` -eq 1 ]; then
    if [ `systemctl is-enabled smbd | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "Samba service is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mSamba service is enabled\e[0m"
    fi
else
    # Do nothing
    echo "Samba is not installed"
fi

# Ensure SSH does not permit empty passwords
echo "Checking if SSH does not permit empty passwords..."
if [ `cat /etc/ssh/sshd_config | grep "PermitEmptyPasswords no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH does not permit empty passwords"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH permits empty passwords\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/ssh/sshd_config..."
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        # Fix the issue
        echo "Fixing /etc/ssh/sshd_config..."
        echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
    fi
fi

# Ensure ssh root login is disabled
echo "Checking if SSH root login is disabled..."
if [ `cat /etc/ssh/sshd_config | grep "PermitRootLogin no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH root login is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH root login is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/ssh/sshd_config..."
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        # Fix the issue
        echo "Fixing /etc/ssh/sshd_config..."
        echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    fi
fi

# Ensure UFW protection is enabled
echo "Checking if UFW protection is enabled..."
if [ `ufw status | grep "Status: active" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "UFW protection is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUFW protection is disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable UFW
        echo "Enabling UFW..."
        ufw enable
    fi
fi

# Check if bash is updated
echo "Checking if bash is updated..."
if [ `apt list --upgradable | grep bash | wc -l` -eq 0 ]; then
    # Do nothing
    echo "bash is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mbash is not updated\e[0m"
fi

# Ensure glibc is updated
echo "Checking if glibc is updated..."
if [ `apt list --upgradable | grep libc6 | wc -l` -eq 0 ]; then
    # Do nothing
    echo "glibc is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mglibc is not updated\e[0m"
fi

# Ensure glibc-common is updated
echo "Checking if glibc-common is updated..."
if [ `apt list --upgradable | grep libc-bin | wc -l` -eq 0 ]; then
    # Do nothing
    echo "glibc-common is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mglibc-common is not updated\e[0m"
fi

# Ensure ICMP echo requests are ignored
echo "Checking if ICMP echo requests are ignored..."
if [ `cat /etc/sysctl.conf | grep "net.ipv4.icmp_echo_ignore_all = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ICMP echo requests are ignored"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mICMP echo requests are not ignored\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysctl.conf..."
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
        # Fix the issue
        echo "Fixing /etc/sysctl.conf..."
        echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
    fi
fi

# Ensure IPv4 does not accept ICMP redirect
echo "Checking if IPv4 does not accept ICMP redirect..."
if [ `cat /etc/sysctl.conf | grep "net.ipv4.conf.all.accept_redirects = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "IPv4 does not accept ICMP redirect"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mIPv4 accepts ICMP redirect\e[0m"
fi

# Ensure IPv4 has source route verification enabled
echo "Checking if IPv4 has source route verification enabled..."
if [ `cat /etc/sysctl.conf | grep "net.ipv4.conf.all.accept_source_route = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "IPv4 has source route verification enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mIPv4 does not have source route verification enabled\e[0m"
fi

# Ensure IPv4 TCP and SYN cookies are enabled
echo "Checking if IPv4 TCP and SYN cookies are enabled..."
if [ `cat /etc/sysctl.conf | grep "net.ipv4.tcp_syncookies = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "IPv4 TCP and SYN cookies are enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mIPv4 TCP and SYN cookies are not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysctl.conf..."
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
        # Fix the issue
        echo "Fixing /etc/sysctl.conf..."
        echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
    fi
fi

# If ngnix is installed, ensure it is updated
echo "Checking if nginx is updated..."
if [ `apt list --upgradable | grep nginx | wc -l` -eq 0 ]; then
    # Do nothing
    echo "nginx is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mnginx is not updated\e[0m"
fi

# Ensure POP3 service is disabled if we have it installed
echo "Checking if POP3 service is disabled..."
if [ `apt list --installed | grep pop3 | wc -l` -eq 0 ]; then
    # Do nothing
    echo "POP3 service is not installed"
else
    if [ `systemctl is-enabled pop3 | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "POP3 service is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mPOP3 service is enabled\e[0m"
    fi
fi

# Ensure we have no phpinfo() files
echo "Checking if we have no phpinfo() files..."
if [ `find /var/www/html -name "phpinfo.php" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No phpinfo() files"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mphpinfo() files detected\e[0m"
fi

# Ensure SMTP service is disabled if we have one installed
echo "Checking if SMTP service is disabled..."
if [ `apt list --installed | grep smtp | wc -l` -eq 0 ]; then
    # Do nothing
    echo "SMTP service is not installed"
else
    if [ `systemctl is-enabled smtp | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "SMTP service is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mSMTP service is enabled\e[0m"
    fi
fi

# If we have squid proxy service installed, ensure it is disabled
echo "Checking if squid proxy service is disabled..."
if [ `apt list --installed | grep squid | wc -l` -eq 0 ]; then
    # Do nothing
    echo "squid proxy service is not installed"
else
    if [ `systemctl is-enabled squid | grep disabled | wc -l` -eq 1 ]; then
        # Do nothing
        echo "squid proxy service is disabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31msquid proxy service is enabled\e[0m"
    fi
fi

# Ensure sudo is updated
echo "Checking if sudo is updated..."
if [ `apt list --upgradable | grep sudo | wc -l` -eq 0 ]; then
    # Do nothing
    echo "sudo is updated"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31msudo is not updated\e[0m"
fi

# Make sure the system is checking for updates daily
echo "Checking if the system is checking for updates daily..."
if [ `cat /etc/crontab | grep "0 0 * * * root apt update" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "System is checking for updates daily"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSystem is not checking for updates daily\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/crontab..."
        cp /etc/crontab /etc/crontab.bak
        # Fix the issue
        echo "Fixing /etc/crontab..."
        # Scan for updates every day at 00:00
        echo "0 0 * * * root apt update" >> /etc/crontab
    fi
fi

# Check if we have Firefox installed, if so, ensure it is updated
echo "Checking if Firefox is updated..."
if [ `apt list --installed | grep firefox | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Firefox is not installed"
else
    if [ `apt list --upgradable | grep firefox | wc -l` -eq 0 ]; then
        # Do nothing
        echo "Firefox is updated"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mFirefox is not updated\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Backup the file
            echo "Backing up /etc/apt/sources.list..."
            cp /etc/apt/sources.list /etc/apt/sources.list.bak
            # Fix the issue
            echo "Fixing /etc/apt/sources.list..."
            # Add the Firefox repository
            echo "deb http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu bionic main" >> /etc/apt/sources.list
            # Update the package list
            apt update
            # Upgrade Firefox
            apt install firefox
        fi
    fi
fi

# Check if PostgreSQL is installed
echo "Checking if PostgreSQL is installed..."
if [ `apt list --installed | grep postgresql | wc -l` -eq 0 ]; then
    # Do nothing
    echo "PostgreSQL is not installed"
else
   # Ensure PostegreSQL has SSL enabled
    echo "Checking if PostgreSQL has SSL enabled..."
    if [ `cat /etc/postgresql/10/main/postgresql.conf | grep "ssl = on" | wc -l` -eq 1 ]; then
        # Do nothing
        echo "PostgreSQL has SSL enabled"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mPostgreSQL does not have SSL enabled\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Backup the file
            echo "Backing up /etc/postgresql/10/main/postgresql.conf..."
            cp /etc/postgresql/10/main/postgresql.conf /etc/postgresql/10/main/postgresql.conf.bak
            # Fix the issue
            echo "Fixing /etc/postgresql/10/main/postgresql.conf..."
            # Enable SSL
            echo "ssl = on" >> /etc/postgresql/10/main/postgresql.conf
        fi
    fi
    # Ensure PostgreSQL requires authentication connections
    echo "Checking if PostgreSQL requires authentication connections..."
    if [ `cat /etc/postgresql/10/main/pg_hba.conf | grep "hostssl all all" | wc-l` -eq 1 ]; then
        # Do nothing
        echo "PostgreSQL requires authentication connections"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mPostgreSQL does not require authentication connections\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Backup the file
            echo "Backing up /etc/postgresql/10/main/pg_hba.conf..."
            cp /etc/postgresql/10/main/pg_hba.conf /etc/postgresql/10/main/pg_hba.conf.bak
            # Fix the issue
            echo "Fixing /etc/postgresql/10/main/pg_hba.conf..."
            # Require authentication connections
            echo "hostssl all all" >> /etc/postgresql/10/main/pg_hba.conf
        fi
    fi
    # Ensure PostgreSQL does not map any user to the postgres user
    echo "Checking if PostgreSQL does not map any user to the postgres user..."
    if [ `cat /etc/postgresql/10/main/pg_hba.conf | grep "map=postgres" | wc -l` -eq 0 ]; then
        # Do nothing
        echo "PostgreSQL does not map any user to the postgres user"
    else
        # Increment detection counter
        detection_counter=$((detection_counter+1))
        # Log the detection in red
        echo -e "\e[31mPostgreSQL maps a user to the postgres user\e[0m"
        # If modifications are allowed, fix the issue
        if [ $allow_modifications -eq 1 ]; then
            # Backup the file
            echo "Backing up /etc/postgresql/10/main/pg_hba.conf..."
            cp /etc/postgresql/10/main/pg_hba.conf /etc/postgresql/10/main/pg_hba.conf.bak
            # Fix the issue
            echo "Fixing /etc/postgresql/10/main/pg_hba.conf..."
            # Remove the mapping
            sed -i '/map=postgres/d' /etc/postgresql/10/main/pg_hba.conf
        fi
    fi
fi

# Ensure you cannot mount a cramfs filesystem using modprobe
echo "Checking if you cannot mount a cramfs filesystem using modprobe..."
if [ `cat /etc/modprobe.d/CIS.conf | grep "install cramfs /bin/true" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "You cannot mount a cramfs filesystem using modprobe"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mYou can mount a cramfs filesystem using modprobe\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/modprobe.d/CIS.conf..."
        cp /etc/modprobe.d/CIS.conf /etc/modprobe.d/CIS.conf.bak
        # Fix the issue
        echo "Fixing /etc/modprobe.d/CIS.conf..."
        # Disable cramfs
        echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
    fi
fi

# Ensure you cannot mount a freevxfs filesystem using modprobe
echo "Checking if you cannot mount a freevxfs filesystem using modprobe..."
if [ `cat /etc/modprobe.d/freevxfs.conf | grep "install freevxfs /bin/true" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "You cannot mount a freevxfs filesystem using modprobe"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mYou can mount a freevxfs filesystem using modprobe\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/modprobe.d/freevxfs.conf..."
        cp /etc/modprobe.d/CIS.conf /etc/modprobe.d/freevxfs.conf.bak
        # Fix the issue
        echo "Fixing /etc/modprobe.d/freevxfs.conf..."
        # Disable freevxfs
        echo "install freevxfs /bin/true" >> /etc/modprobe.d/freevxfs.conf
    fi
fi

# Ensure /tmp is configured correctly
echo "Checking if /tmp is configured correctly..."
if [ `cat /etc/fstab | grep "/tmp" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "/tmp is configured correctly"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31m/tmp is not configured correctly\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /tmp
        echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi
fi

# Ensure separate partition exists for /var
echo "Checking if separate partition exists for /var..."
if [ `cat /etc/fstab | grep "/var" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Separate partition exists for /var"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSeparate partition does not exist for /var\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /var
        echo "/dev/sda2 /var ext4 defaults 0 2" >> /etc/fstab
    fi
fi

# Ensure separate partition exists for /var/tmp
echo "Checking if separate partition exists for /var/tmp..."
if [ `cat /etc/fstab | grep "/var/tmp" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Separate partition exists for /var/tmp"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSeparate partition does not exist for /var/tmp\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /var/tmp
        echo "tmpfs /var/tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi
fi

# Ensure separate partition exists for /var/log
echo "Checking if separate partition exists for /var/log..."
if [ `cat /etc/fstab | grep "/var/log" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Separate partition exists for /var/log"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSeparate partition does not exist for /var/log\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /var/log
        echo "tmpfs /var/log tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi
fi

# Ensure separate partition exists for /var/log/audit
echo "Checking if separate partition exists for /var/log/audit..."
if [ `cat /etc/fstab | grep "/var/log/audit" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Separate partition exists for /var/log/audit"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSeparate partition does not exist for /var/log/audit\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /var/log/audit
        echo "tmpfs /var/log/audit tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    fi
fi

# Ensure separate partition exists for /home
echo "Checking if separate partition exists for /home..."
if [ `cat /etc/fstab | grep "/home" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Separate partition exists for /home"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSeparate partition does not exist for /home\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure /home
        echo "/dev/sda3 /home ext4 defaults 0 2" >> /etc/fstab
    fi
fi

# Ensure nodev option set on /home
echo "Checking if nodev option is set on /home..."
if [ `cat /etc/fstab | grep "/home" | grep "nodev" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "nodev option is set on /home"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mnodev option is not set on /home\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure nodev option on /home
        sed -i 's/\/home/\/home nodev/g' /etc/fstab
    fi
fi

# Ensure nodev option set on /dev/shm partition
echo "Checking if nodev option is set on /dev/shm partition..."
if [ `cat /etc/fstab | grep "/dev/shm" | grep "nodev" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "nodev option is set on /dev/shm partition"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mnodev option is not set on /dev/shm partition\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/fstab..."
        cp /etc/fstab /etc/fstab.bak
        # Fix the issue
        echo "Fixing /etc/fstab..."
        # Configure nodev option on /dev/shm partition
        sed -i 's/\/dev\/shm/\/dev\/shm nodev/g' /etc/fstab
    fi
fi

# Ensure automounting is disabled
echo "Checking if automounting is disabled..."
if [ `systemctl is-enabled autofs | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Automounting is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mAutomounting is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix the issue
        echo "Disabling automounting..."
        systemctl disable autofs
    fi
fi

# Ensure USB storage is disabled with lsmod
echo "Checking if USB storage is disabled with lsmod..."
if [ `lsmod | grep "usb-storage" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "USB storage is disabled with lsmod"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUSB storage is not disabled with lsmod\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix the issue
        echo "Disabling USB storage with lsmod..."
        rmmod usb-storage
    fi
fi

# Ensure sudo commands use pty
echo "Checking if sudo commands use pty..."
if [ `cat /etc/sudoers | grep "Defaults    requiretty" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Sudo commands use pty"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSudo commands do not use pty\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sudoers..."
        cp /etc/sudoers /etc/sudoers.bak
        # Fix the issue
        echo "Fixing /etc/sudoers..."
        # Configure sudo commands to use pty
        echo "Defaults    requiretty" >> /etc/sudoers
    fi
fi

# Ensure a sudo log file exists
echo "Checking if a sudo log file exists..."
if [ `cat /etc/sudoers | grep "logfile" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "A sudo log file exists"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mA sudo log file does not exist\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sudoers..."
        cp /etc/sudoers /etc/sudoers.bak
        # Fix the issue
        echo "Fixing /etc/sudoers..."
        # Configure a sudo log file
        echo "Defaults    logfile=/var/log/sudo.log" >> /etc/sudoers
    fi
fi

# Ensure permissions on bootloader config are configured
echo "Checking if permissions on bootloader config are configured..."
if [ `stat -c %a /boot/grub2/grub.cfg | grep "600" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on bootloader config are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on bootloader config are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix the issue
        echo "Fixing permissions on bootloader config..."
        chmod 600 /boot/grub2/grub.cfg
    fi
fi

# Ensure bootloader password is set
echo "Checking if bootloader password is set..."
if [ `cat /boot/grub2/grub.cfg | grep "password" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Bootloader password is set"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mBootloader password is not set\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix the issue
        echo "Setting bootloader password..."
        # Configure bootloader password
        grub2-setpassword
    fi
fi

# Ensure authentication is required for single user mode
echo "Checking if authentication is required for single user mode..."
if [ `cat /etc/sysconfig/init | grep "SINGLE" | grep "SULOGIN" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Authentication is required for single user mode"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mAuthentication is not required for single user mode\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysconfig/init..."
        cp /etc/sysconfig/init /etc/sysconfig/init.bak
        # Fix the issue
        echo "Fixing /etc/sysconfig/init..."
        # Configure authentication for single user mode
        sed -i 's/SINGLE=/SINGLE=\/sbin\/sulogin/g' /etc/sysconfig/init
    fi
fi

# Ensure interactive boot is not enabled
echo "Checking if interactive boot is not enabled..."
if [ `cat /etc/sysconfig/init | grep "PROMPT" | grep "no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Interactive boot is not enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mInteractive boot is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysconfig/init..."
        cp /etc/sysconfig/init /etc/sysconfig/init.bak
        # Fix the issue
        echo "Fixing /etc/sysconfig/init..."
        # Configure interactive boot
        sed -i 's/PROMPT=no/PROMPT=yes/g' /etc/sysconfig/init
    fi
fi

# Ensure XD/NX support is enabled
echo "Checking if XD/NX support is enabled..."
if [ `cat /etc/sysconfig/init | grep "noexec" | grep "nosuid" | grep "nodev" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "XD/NX support is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mXD/NX support is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysconfig/init..."
        cp /etc/sysconfig/init /etc/sysconfig/init.bak
        # Fix the issue
        echo "Fixing /etc/sysconfig/init..."
        # Configure XD/NX support
        sed -i 's/noexec,nosuid,nodev/noexec,nosuid,nodev,relatime/g' /etc/sysconfig/init
    fi
fi

# Ensure ASLR is enabled
echo "Checking if ASLR is enabled..."
if [ `cat /etc/sysconfig/init | grep "noexec" | grep "nosuid" | grep "nodev" | grep "randomize_va_space" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ASLR is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mASLR is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/sysconfig/init..."
        cp /etc/sysconfig/init /etc/sysconfig/init.bak
        # Fix the issue
        echo "Fixing /etc/sysconfig/init..."
        # Configure ASLR
        sed -i 's/noexec,nosuid,nodev,noexec,nosuid,nodev,relatime/noexec,nosuid,nodev,noexec,nosuid,nodev,relatime,randomize_va_space/g' /etc/sysconfig/init
    fi
fi

# Ensure core dumps are restricted
echo "Checking if core dumps are restricted..."
if [ `cat /etc/security/limits.conf | grep "hard core" | grep "0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Core dumps are restricted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mCore dumps are not restricted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/security/limits.conf..."
        cp /etc/security/limits.conf /etc/security/limits.conf.bak
        # Fix the issue
        echo "Fixing /etc/security/limits.conf..."
        # Configure core dumps
        echo "* hard core 0" >> /etc/security/limits.conf
        # Set suid_dumpable to 0
        echo "Setting suid_dumpable to 0..."
        sysctl -w fs.suid_dumpable=0
        # If systemctl-coredump is installed, set storage and process size to 0
        if [ `rpm -qa | grep "systemd-coredump" | wc -l` -eq 1 ]; then
            # Set storage to 0
            echo "Setting storage to 0..."
            sed -i 's/Storage=external/Storage=none/g' /etc/systemd/coredump.conf
            # Set process size to 0
            echo "Setting process size to 0..."
            sed -i 's/ProcessSizeMax=0/ProcessSizeMax=0/g' /etc/systemd/coredump.conf
        fi
    fi
fi

# Ensure motd is configured
echo "Checking if motd is configured..."
if [ `cat /etc/motd | grep "Authorized uses only. All activity may be monitored and reported." | wc -l` -eq 1 ]; then
    # Do nothing
    echo "motd is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mmotd is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/motd..."
        cp /etc/motd /etc/motd.bak
        # Fix the issue
        echo "Fixing /etc/motd..."
        # Configure motd
        echo "Authorized uses only. All activity may be monitored and reported." > /etc/motd
    fi
fi

# Ensure local login warning banner is configured
echo "Checking if local login warning banner is configured..."
if [ `cat /etc/issue | grep "Authorized uses only. All activity may be monitored and reported." | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Local login warning banner is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLocal login warning banner is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/issue..."
        cp /etc/issue /etc/issue.bak
        # Fix the issue
        echo "Fixing /etc/issue..."
        # Configure local login warning banner
        echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
    fi
fi

# Ensure remote login warning banner is configured
echo "Checking if remote login warning banner is configured..."
if [ `cat /etc/issue.net | grep "Authorized uses only. All activity may be monitored and reported." | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Remote login warning banner is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mRemote login warning banner is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/issue.net..."
        cp /etc/issue.net /etc/issue.net.bak
        # Fix the issue
        echo "Fixing /etc/issue.net..."
        # Configure remote login warning banner
        echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net
    fi
fi

# Ensure permissions on /etc/motd are configured
echo "Checking if permissions on /etc/motd are configured..."
if [ `stat -c %a /etc/motd | grep "644" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/motd are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/motd are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/motd..."
        cp /etc/motd /etc/motd.bak
        # Fix the issue
        echo "Fixing /etc/motd..."
        # Configure permissions on /etc/motd
        chmod 644 /etc/motd
    fi
fi

# Ensure permissions on /etc/issue are configured
echo "Checking if permissions on /etc/issue are configured..."
if [ `stat -c %a /etc/issue | grep "644" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/issue are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/issue are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/issue..."
        cp /etc/issue /etc/issue.bak
        # Fix the issue
        echo "Fixing /etc/issue..."
        # Configure permissions on /etc/issue
        chmod 644 /etc/issue
    fi
fi

# Ensure permissions on /etc/issue.net are configured
echo "Checking if permissions on /etc/issue.net are configured..."
if [ `stat -c %a /etc/issue.net | grep "644" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/issue.net are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/issue.net are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/issue.net..."
        cp /etc/issue.net /etc/issue.net.bak
        # Fix the issue
        echo "Fixing /etc/issue.net..."
        # Configure permissions on /etc/issue.net
        chmod 644 /etc/issue.net
    fi
fi

# Ensure GDM login banner is configured
echo "Checking if GDM login banner is configured..."
if [ `cat /etc/dconf/db/local.d/01-banner-message | grep "banner-message-enable=true" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "GDM login banner is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mGDM login banner is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/dconf/db/local.d/01-banner-message..."
        cp /etc/dconf/db/local.d/01-banner-message /etc/dconf/db/local.d/01-banner-message.bak
        # Fix the issue
        echo "Fixing /etc/dconf/db/local.d/01-banner-message..."
        # Configure GDM login banner
        echo "[org/gnome/login-screen]" > /etc/dconf/db/local.d/01-banner-message
        echo "banner-message-enable=true" >> /etc/dconf/db/local.d/01-banner-message
        echo "banner-message-text='Authorized uses only. All activity may be monitored and reported.'" >> /etc/dconf/db/local.d/01-banner-message
    fi
fi

# If xinetd is installed, remove it (ubuntu)
echo "Checking if xinetd is installed..."
if [ `dpkg -s xinetd | grep "Status: install ok installed" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mxinetd is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove xinetd
        echo "Removing xinetd..."
        apt-get remove xinetd -y
        # Purge
        apt-get purge xinetd -y
    fi
else
    # Do nothing
    echo "xinetd is not installed"
fi

# If openbsd-inetd is installed, remove it (ubuntu)
echo "Checking if openbsd-inetd is installed..."
if [ `dpkg -s openbsd-inetd | grep "Status: install ok installed" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mopenbsd-inetd is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove openbsd-inetd
        echo "Removing openbsd-inetd..."
        apt-get remove openbsd-inetd -y
        # Purge
        apt-get purge openbsd-inetd -y
    fi
else
    # Do nothing
    echo "openbsd-inetd is not installed"
fi

# Ensure time synchronization is in use
echo "Checking if time synchronization is in use..."
if [ `timedatectl | grep "NTP enabled: yes" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Time synchronization is in use"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mTime synchronization is not in use\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Fix the issue
        echo "Fixing time synchronization..."
        # Install NTP if it is not installed
        if [ `dpkg -s ntp | grep "Status: install ok installed" | wc -l` -eq 0 ]; then
            echo "Installing NTP..."
            apt-get install ntp -y
        fi
        # Enable time synchronization
        timedatectl set-ntp true
    fi
fi

# Ensure systemd-timesyncd is configured
echo "Checking if systemd-timesyncd is configured..."
if [ `cat /etc/systemd/timesyncd.conf | grep "NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org 3.ubuntu.pool.ntp.org" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "systemd-timesyncd is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31msystemd-timesyncd is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/systemd/timesyncd.conf..."
        cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak
        # Fix the issue
        systemctl enable systemd-timesyncd.service
        echo "Fixing /etc/systemd/timesyncd.conf..."
        # Configure systemd-timesyncd
        echo "[Time]" > /etc/systemd/timesyncd.conf
        echo "NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org 3.ubuntu.pool.ntp.org" >> /etc/systemd/timesyncd.conf
        echo "FallbackNTP=ntp.ubuntu.com" >> /etc/systemd/timesyncd.conf
        systemctl start systemd-timesyncd.service 
        timedatectl set-ntp true
    fi
fi

# Ensure NTP is configured
echo "Checking if NTP is configured..."
if [ `cat /etc/ntp.conf | grep "server 0.ubuntu.pool.ntp.org" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "NTP is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mNTP is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Backup the file
        echo "Backing up /etc/ntp.conf..."
        cp /etc/ntp.conf /etc/ntp.conf.bak
        # Fix the issue
        echo "Fixing /etc/ntp.conf..."
        # Configure NTP
        echo "server 0.ubuntu.pool.ntp.org" > /etc/ntp.conf
        echo "server 1.ubuntu.pool.ntp.org" >> /etc/ntp.conf
        echo "server 2.ubuntu.pool.ntp.org" >> /etc/ntp.conf
        echo "server 3.ubuntu.pool.ntp.org" >> /etc/ntp.conf
        # Restart NTP
        echo "Restarting NTP..."
        service ntp restart
    fi
fi

# Ensure Avahi Server is not enabled
echo "Checking if Avahi Server is enabled..."
if [ `systemctl is-enabled avahi-daemon | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Avahi Server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mAvahi Server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable Avahi Server
        echo "Disabling Avahi Server..."
        systemctl disable avahi-daemon
    fi
fi

# Ensure CUPS is not enabled
echo "Checking if CUPS is enabled..."
if [ `systemctl is-enabled cups | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "CUPS is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mCUPS is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable CUPS
        echo "Disabling CUPS..."
        systemctl disable cups
    fi
fi

# Ensure DHCP Server is not enabled
echo "Checking if DHCP Server is enabled..."
if [ `systemctl is-enabled isc-dhcp-server | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "DHCP Server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDHCP Server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable DHCP Server
        echo "Disabling DHCP Server..."
        systemctl disable isc-dhcp-server
    fi
fi

# Ensure LDAP server is not enabled
echo "Checking if LDAP server is enabled..."
if [ `systemctl is-enabled slapd | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "LDAP server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLDAP server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable LDAP server
        echo "Disabling LDAP server..."
        systemctl disable slapd
    fi
fi

# Ensure NFS and RPC are not enabled
echo "Checking if NFS and RPC are enabled..."
if [ `systemctl is-enabled nfs-kernel-server | grep "disabled" | wc -l` -eq 1 ] && [ `systemctl is-enabled rpcbind | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "NFS and RPC are disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mNFS and RPC are enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable NFS and RPC
        echo "Disabling NFS and RPC..."
        systemctl disable nfs-kernel-server
        systemctl disable rpcbind
    fi
fi

# Ensure email server is not enabled
echo "Checking if email server is enabled..."
if [ `systemctl is-enabled postfix | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Email server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mEmail server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable email server
        echo "Disabling email server..."
        systemctl disable postfix
    fi
fi

# Check for dovecot
echo "Checking if dovecot is installed..."
if [ `dpkg -l | grep "dovecot" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mdovecot is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # disable
        systemctl disable dovecot
        # Remove dovecot
        echo "Removing dovecot..."
        apt-get remove dovecot -y
    fi
fi

# Ensure SNMP Server is not enabled
echo "Checking if SNMP Server is enabled..."
if [ `systemctl is-enabled snmpd | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SNMP Server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSNMP Server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable SNMP Server
        echo "Disabling SNMP Server..."
        systemctl disable snmpd
    fi
fi

# Ensure mail transfer agent is configured for local-only mode
echo "Checking if mail transfer agent is configured for local-only mode..."
if [ `grep "inet_interfaces = loopback-only" /etc/postfix/main.cf | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Mail transfer agent is configured for local-only mode"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mMail transfer agent is not configured for local-only mode\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure mail transfer agent for local-only mode
        echo "Configuring mail transfer agent for local-only mode..."
        echo "inet_interfaces = loopback-only" >> /etc/postfix/main.cf
        # Restart mail transfer agent
        echo "Restarting mail transfer agent..."
        systemctl restart postfix
    fi
fi

# Ensure rsync service is not enabled
echo "Checking if rsync service is enabled..."
if [ `systemctl is-enabled rsync | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "rsync service is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mrsync service is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable rsync service
        echo "Disabling rsync service..."
        systemctl disable rsync
    fi
fi

# Ensure NIS server is not enabled
echo "Checking if NIS server is enabled..."
if [ `systemctl is-enabled nis | grep "disabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "NIS server is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mNIS server is enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable NIS server
        echo "Disabling NIS server..."
        systemctl disable nis
        # Purge NIS
        echo "Purging NIS..."
        apt-get purge nis -y
    fi
fi

# Ensure rsh client is not installed
echo "Checking if rsh client is installed..."
if [ `dpkg -l | grep "rsh-client" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mrsh client is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove rsh client
        echo "Removing rsh client..."
        apt-get remove rsh-client -y
    fi
fi

# Ensure talk client is not installed
echo "Checking if talk client is installed..."
if [ `dpkg -l | grep "talk" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mtalk client is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove talk client
        echo "Removing talk client..."
        apt-get remove talk -y
    fi
fi

# Ensure telnet client is not installed
echo "Checking if telnet client is installed..."
if [ `dpkg -l | grep "telnet" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mtelnet client is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove telnet client
        echo "Removing telnet client..."
        apt-get remove telnet -y
    fi
fi

# Ensure LDAP client is not installed
echo "Checking if LDAP client is installed..."
if [ `dpkg -l | grep "ldap-utils" | wc -l` -eq 1 ]; then
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLDAP client is installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Remove LDAP client
        echo "Removing LDAP client..."
        apt-get remove ldap-utils -y
    fi
fi

## Network Configuration ##
# Ensure packet redirect sending is disabled
echo "Checking if packet redirect sending is disabled..."
if [ `sysctl net.ipv4.conf.all.send_redirects | grep "net.ipv4.conf.all.send_redirects = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Packet redirect sending is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPacket redirect sending is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable packet redirect sending
        echo "Disabling packet redirect sending..."
        sysctl -w net.ipv4.conf.all.send_redirects=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.send_redirects=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.send_redirects=0
        sysctl -w net.ipv4.conf.all.send_redirects=0
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure ip forwarding is disabled
echo "Checking if ip forwarding is disabled..."
if [ `sysctl net.ipv4.ip_forward | grep "net.ipv4.ip_forward = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ip forwarding is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mip forwarding is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable ip forwarding
        echo "Disabling ip forwarding..."
        sysctl -w net.ipv4.ip_forward=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.ip_forward=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.ip_forward=0
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure source routed packets are not accepted
echo "Checking if source routed packets are not accepted..."
if [ `sysctl net.ipv4.conf.all.accept_source_route | grep "net.ipv4.conf.all.accept_source_route = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Source routed packets are not accepted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSource routed packets are accepted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable source routed packets
        echo "Disabling source routed packets..."
        sysctl -w net.ipv4.conf.all.accept_source_route=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.accept_source_route=0" >> /etc/sysctl.conf
        echo "net.ipv6.conf.all.accept_source_route=0" >> /etc/sysctl.conf
        echo "net.ipv6.conf.default.accept_source_route=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.accept_source_route=0
        sysctl -w net.ipv4.conf.all.accept_source_route=0
        sysctl -w net.ipv4.route.flush=1
        sysctl -w net.ipv6.conf.all.accept_source_route=0
        sysctl -w net.ipv6.conf.default.accept_source_route=0
        sysctl -w net.ipv6.route.flush=1
    fi
fi

# Ensure ICMP redirects are not accepted
echo "Checking if ICMP redirects are not accepted..."
if [ `sysctl net.ipv4.conf.all.accept_redirects | grep "net.ipv4.conf.all.accept_redirects = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ICMP redirects are not accepted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mICMP redirects are accepted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable ICMP redirects
        echo "Disabling ICMP redirects..."
        sysctl -w net.ipv4.conf.all.accept_redirects=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.conf
        echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf
        echo "net.ipv6.conf.default.accept_redirects=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.accept_redirects=0
        sysctl -w net.ipv4.conf.all.accept_redirects=0
        sysctl -w net.ipv4.route.flush=1
        sysctl -w net.ipv6.conf.all.accept_redirects=0
        sysctl -w net.ipv6.conf.default.accept_redirects=0
        sysctl -w net.ipv6.route.flush=1
    fi
fi

# Ensure secure ICMP redirects are not accepted
echo "Checking if secure ICMP redirects are not accepted..."
if [ `sysctl net.ipv4.conf.all.secure_redirects | grep "net.ipv4.conf.all.secure_redirects = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Secure ICMP redirects are not accepted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSecure ICMP redirects are accepted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable secure ICMP redirects
        echo "Disabling secure ICMP redirects..."
        sysctl -w net.ipv4.conf.all.secure_redirects=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.secure_redirects=0" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.secure_redirects=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.secure_redirects=0
        sysctl -w net.ipv4.conf.all.secure_redirects=0
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure suspicious packets are logged
echo "Checking if suspicious packets are logged..."
if [ `sysctl net.ipv4.conf.all.log_martians | grep "net.ipv4.conf.all.log_martians = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Suspicious packets are logged"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSuspicious packets are not logged\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable suspicious packets logging
        echo "Enabling suspicious packets logging..."
        sysctl -w net.ipv4.conf.all.log_martians=1
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.log_martians=1
        sysctl -w net.ipv4.conf.all.log_martians=1
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure broadcast ICMP requests are ignored
echo "Checking if broadcast ICMP requests are ignored..."
if [ `sysctl net.ipv4.icmp_echo_ignore_broadcasts | grep "net.ipv4.icmp_echo_ignore_broadcasts = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Broadcast ICMP requests are ignored"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mBroadcast ICMP requests are not ignored\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Ignore broadcast ICMP requests
        echo "Ignoring broadcast ICMP requests..."
        sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure bogus ICMP responses are ignored
echo "Checking if bogus ICMP responses are ignored..."
if [ `sysctl net.ipv4.icmp_ignore_bogus_error_responses | grep "net.ipv4.icmp_ignore_bogus_error_responses = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Bogus ICMP responses are ignored"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mBogus ICMP responses are not ignored\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Ignore bogus ICMP responses
        echo "Ignoring bogus ICMP responses..."
        sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure reverse path filtering is enabled
echo "Checking if reverse path filtering is enabled..."
if [ `sysctl net.ipv4.conf.all.rp_filter | grep "net.ipv4.conf.all.rp_filter = 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Reverse path filtering is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mReverse path filtering is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable reverse path filtering
        echo "Enabling reverse path filtering..."
        sysctl -w net.ipv4.conf.all.rp_filter=1
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
        echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv4.conf.default.rp_filter=1
        sysctl -w net.ipv4.conf.all.rp_filter=1
        sysctl -w net.ipv4.route.flush=1
    fi
fi

# Ensure ipv6 router advertisements are not accepted
echo "Checking if IPv6 router advertisements are not accepted..."
if [ `sysctl net.ipv6.conf.all.accept_ra | grep "net.ipv6.conf.all.accept_ra = 0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "IPv6 router advertisements are not accepted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mIPv6 router advertisements are accepted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable IPv6 router advertisements
        echo "Disabling IPv6 router advertisements..."
        sysctl -w net.ipv6.conf.all.accept_ra=0
        # Add the sysctl setting to /etc/sysctl.conf
        echo "net.ipv6.conf.all.accept_ra=0" >> /etc/sysctl.conf
        echo "net.ipv6.conf.default.accept_ra=0" >> /etc/sysctl.conf
        # Run commands
        sysctl -w net.ipv6.conf.default.accept_ra=0
        sysctl -w net.ipv6.conf.all.accept_ra=0
        sysctl -w net.ipv6.route.flush=1
    fi
fi

# Ensure permissions on /etc/hosts.allow are configured
echo "Checking if permissions on /etc/hosts.allow are configured..."
if [ `stat -c %a /etc/hosts.allow | grep "644" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/hosts.allow are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/hosts.allow are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set permissions on /etc/hosts.allow
        echo "Setting permissions on /etc/hosts.allow..."
        chmod 644 /etc/hosts.allow
    fi
fi

# Ensure permissions on /etc/hosts.deny are configured
echo "Checking if permissions on /etc/hosts.deny are configured..."
if [ `stat -c %a /etc/hosts.deny | grep "644" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/hosts.deny are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/hosts.deny are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set permissions on /etc/hosts.deny
        echo "Setting permissions on /etc/hosts.deny..."
        chmod 644 /etc/hosts.deny
    fi
fi

# Ensure DCCP is disabled
echo "Checking if DCCP is disabled..."
if [ `lsmod | grep dccp | wc -l` -eq 0 ]; then
    # Do nothing
    echo "DCCP is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDCCP is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable DCCP
        echo "Disabling DCCP..."
        modprobe -r dccp
        # Add the modprobe setting to /etc/modprobe.d/CIS.conf
        echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
    fi
fi

# Ensure SCTP is disabled
echo "Checking if SCTP is disabled..."
if [ `lsmod | grep sctp | wc -l` -eq 0 ]; then
    # Do nothing
    echo "SCTP is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSCTP is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable SCTP
        echo "Disabling SCTP..."
        modprobe -r sctp
        # Add the modprobe setting to /etc/modprobe.d/CIS.conf
        echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
    fi
fi

# Ensure RDS is disabled
echo "Checking if RDS is disabled..."
if [ `lsmod | grep rds | wc -l` -eq 0 ]; then
    # Do nothing
    echo "RDS is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mRDS is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable RDS
        echo "Disabling RDS..."
        modprobe -r rds
        # Add the modprobe setting to /etc/modprobe.d/CIS.conf
        echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
    fi
fi

# Ensure TIPC is disabled
echo "Checking if TIPC is disabled..."
if [ `lsmod | grep tipc | wc -l` -eq 0 ]; then
    # Do nothing
    echo "TIPC is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mTIPC is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable TIPC
        echo "Disabling TIPC..."
        modprobe -r tipc
        # Add the modprobe setting to /etc/modprobe.d/CIS.conf
        echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
    fi
fi

# Ensure UFW is installed
echo "Checking if UFW is installed..."
if [ `dpkg -s ufw | grep "Status: install ok installed" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "UFW is installed"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUFW is not installed\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Install UFW
        echo "Installing UFW..."
        apt-get install ufw -y
    fi
fi

# Ensure UFW service is enabled
echo "Checking if UFW service is enabled..."
if [ `systemctl is-enabled ufw | grep "enabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "UFW service is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUFW service is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable UFW service
        echo "Enabling UFW service..."
        systemctl enable ufw
    fi
fi

# Ensure UFW is enabled
echo "Checking if UFW is enabled..."
if [ `ufw status | grep "Status: active" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "UFW is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUFW is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable UFW
        echo "Enabling UFW..."
        ufw enable
    fi
fi

# Ensure default deny firewall policy
echo "Checking if default deny firewall policy is set..."
if [ `ufw status | grep "Default: deny (incoming)" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Default deny firewall policy is set"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDefault deny firewall policy is not set\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Set default deny firewall policy
        echo "Setting default deny firewall policy..."
        ufw default deny incoming
        ufw default deny outgoing
        ufw default deny routed
    fi
fi

# Ensure UFW loopback traffic is configured
echo "Checking if UFW loopback traffic is configured..."
if [ `ufw status | grep "Anywhere on lo0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "UFW loopback traffic is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUFW loopback traffic is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure UFW loopback traffic
        echo "Configuring UFW loopback traffic..."
        ufw allow in on lo
        ufw deny in from 127.0.0.0/8
        ufw deny in from ::1
    fi
fi

# Ensure wireless interfaces are disabled
echo "Checking if wireless interfaces are disabled..."
if [ `iwconfig 2>/dev/null | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Wireless interfaces are disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mWireless interfaces are not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable wireless interfaces
        echo "Disabling wireless interfaces..."
        for interface in `iwconfig 2>/dev/null | cut -d " " -f 1`; do
            ifconfig $interface down
        done
    fi
fi

### Access, Authentication and Authorization ###
# Ensure cron daemon is enabled
echo "Checking if cron daemon is enabled..."
if [ `systemctl is-enabled cron | grep "enabled" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Cron daemon is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mCron daemon is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Enable cron daemon
        echo "Enabling cron daemon..."
        systemctl enable cron
    fi
fi

# Ensure permissions on /etc/crontab are configured
echo "Checking if permissions on /etc/crontab are configured..."
if [ `stat -c %a /etc/crontab | grep "600" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/crontab are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/crontab are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/crontab
        echo "Configuring permissions on /etc/crontab..."
        chown root:root /etc/crontab
        chmod 600 /etc/crontab
    fi
fi

# Ensure permissions on /etc/cron.hourly are configured
echo "Checking if permissions on /etc/cron.hourly are configured..."
if [ `stat -c %a /etc/cron.hourly | grep "700" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/cron.hourly are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/cron.hourly are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/cron.hourly
        echo "Configuring permissions on /etc/cron.hourly..."
        chown root:root /etc/cron.hourly
        chmod 700 /etc/cron.hourly
    fi
fi

# Ensure permissions on /etc/cron.daily are configured
echo "Checking if permissions on /etc/cron.daily are configured..."
if [ `stat -c %a /etc/cron.daily | grep "700" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/cron.daily are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/cron.daily are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/cron.daily
        echo "Configuring permissions on /etc/cron.daily..."
        chown root:root /etc/cron.daily
        chmod 700 /etc/cron.daily
    fi
fi

# Ensure permissions on /etc/cron.weekly are configured
echo "Checking if permissions on /etc/cron.weekly are configured..."
if [ `stat -c %a /etc/cron.weekly | grep "700" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/cron.weekly are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/cron.weekly are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/cron.weekly
        echo "Configuring permissions on /etc/cron.weekly..."
        chown root:root /etc/cron.weekly
        chmod 700 /etc/cron.weekly
    fi
fi

# Ensure permissions on /etc/cron.monthly are configured
echo "Checking if permissions on /etc/cron.monthly are configured..."
if [ `stat -c %a /etc/cron.monthly | grep "700" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/cron.monthly are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/cron.monthly are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/cron.monthly
        echo "Configuring permissions on /etc/cron.monthly..."
        chown root:root /etc/cron.monthly
        chmod 700 /etc/cron.monthly
    fi
fi

# Ensure permissions on /etc/cron.d are configured
echo "Checking if permissions on /etc/cron.d are configured..."
if [ `stat -c %a /etc/cron.d | grep "700" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/cron.d are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/cron.d are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/cron.d
        echo "Configuring permissions on /etc/cron.d..."
        chown root:root /etc/cron.d
        chmod 700 /etc/cron.d
    fi
fi

# Ensure at/cron is restricted to authorized users
echo "Checking if at/cron is restricted to authorized users..."
if [ `cat /etc/cron.allow | grep "root" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "at/cron is restricted to authorized users"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mat/cron is not restricted to authorized users\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure at/cron to be restricted to authorized users
        echo "Configuring at/cron to be restricted to authorized users..."
        rm /etc/cron.deny
        rm /etc/at.deny
        touch /etc/cron.allow
        touch /etc/at.allow
        chmod o-rwx /etc/cron.allow
        chmod g-wx /etc/cron.allow
        chmod o-rwx /etc/at.allow
        chmod g-wx /etc/at.allow
        chown root:root /etc/cron.allow
        chown root:root /etc/at.allow

    fi
fi

# Ensure permissions on /etc/ssh/sshd_config are configured
echo "Checking if permissions on /etc/ssh/sshd_config are configured..."
if [ `stat -c %a /etc/ssh/sshd_config | grep "600" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/ssh/sshd_config are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/ssh/sshd_config are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/ssh/sshd_config
        echo "Configuring permissions on /etc/ssh/sshd_config..."
        chown root:root /etc/ssh/sshd_config
        chmod 600 /etc/ssh/sshd_config
    fi
fi

# Ensure permissions on ssh private host key files are configured
echo "Checking if permissions on ssh private host key files are configured..."
if [ `stat -c %a /etc/ssh/ssh_host_* | grep "600" | wc -l` -eq 4 ]; then
    # Do nothing
    echo "Permissions on ssh private host key files are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on ssh private host key files are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on ssh private host key files
        echo "Configuring permissions on ssh private host key files..."
        chown root:root /etc/ssh/ssh_host_*
        chmod 600 /etc/ssh/ssh_host_*
    fi
fi

# Ensure permissions on ssh public host key files are configured
echo "Checking if permissions on ssh public host key files are configured..."
if [ `stat -c %a /etc/ssh/ssh_host_* | grep "644" | wc -l` -eq 4 ]; then
    # Do nothing
    echo "Permissions on ssh public host key files are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on ssh public host key files are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on ssh public host key files
        echo "Configuring permissions on ssh public host key files..."
        chown root:root /etc/ssh/ssh_host_*
        chmod 644 /etc/ssh/ssh_host_*
    fi
fi

# Ensure SSH protocol is not set to 1
echo "Checking if SSH protocol is not set to 1..."
if [ `cat /etc/ssh/sshd_config | grep "Protocol 2" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH protocol is not set to 1"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH protocol is set to 1\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH protocol to not be set to 1
        echo "Configuring SSH protocol to not be set to 1..."
        sed -i 's/Protocol 1/Protocol 2/g' /etc/ssh/sshd_config
    fi
fi

# Ensure ssh LogLevel is set to INFO
echo "Checking if ssh LogLevel is set to INFO..."
if [ `cat /etc/ssh/sshd_config | grep "LogLevel INFO" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ssh LogLevel is set to INFO"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mssh LogLevel is not set to INFO\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure ssh LogLevel to be set to INFO
        echo "Configuring ssh LogLevel to be set to INFO..."
        sed -i 's/LogLevel VERBOSE/LogLevel INFO/g' /etc/ssh/sshd_config
    fi
fi

# Ensure SSH X11 forwarding is disabled
echo "Checking if SSH X11 forwarding is disabled..."
if [ `cat /etc/ssh/sshd_config | grep "X11Forwarding no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH X11 forwarding is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH X11 forwarding is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH X11 forwarding to be disabled
        echo "Configuring SSH X11 forwarding to be disabled..."
        sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
    fi
fi

# Ensure ssh max auth tries is set to 4 or less
echo "Checking if ssh max auth tries is set to 4 or less..."
if [ `cat /etc/ssh/sshd_config | grep "MaxAuthTries 4" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "ssh max auth tries is set to 4 or less"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mssh max auth tries is not set to 4 or less\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure ssh max auth tries to be set to 4 or less
        echo "Configuring ssh max auth tries to be set to 4 or less..."
        sed -i 's/MaxAuthTries 6/MaxAuthTries 4/g' /etc/ssh/sshd_config
    fi
fi

# Ensure SSH IgnoreRhosts is enabled
echo "Checking if SSH IgnoreRhosts is enabled..."
if [ `cat /etc/ssh/sshd_config | grep "IgnoreRhosts yes" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH IgnoreRhosts is enabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH IgnoreRhosts is not enabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH IgnoreRhosts to be enabled
        echo "Configuring SSH IgnoreRhosts to be enabled..."
        sed -i 's/IgnoreRhosts no/IgnoreRhosts yes/g' /etc/ssh/sshd_config
    fi
fi

# Ensure SSH HostbasedAuthentication is disabled
echo "Checking if SSH HostbasedAuthentication is disabled..."
if [ `cat /etc/ssh/sshd_config | grep "HostbasedAuthentication no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH HostbasedAuthentication is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH HostbasedAuthentication is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH HostbasedAuthentication to be disabled
        echo "Configuring SSH HostbasedAuthentication to be disabled..."
        sed -i 's/HostbasedAuthentication yes/HostbasedAuthentication no/g' /etc/ssh/sshd_config
    fi
fi

# Ensure SSH PermitUserEnvironment is disabled
echo "Checking if SSH PermitUserEnvironment is disabled..."
if [ `cat /etc/ssh/sshd_config | grep "PermitUserEnvironment no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH PermitUserEnvironment is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH PermitUserEnvironment is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH PermitUserEnvironment to be disabled
        echo "Configuring SSH PermitUserEnvironment to be disabled..."
        sed -i 's/PermitUserEnvironment yes/PermitUserEnvironment no/g' /etc/ssh/sshd_config
    fi
fi

# Ensure only strong SSH Ciphers are used
echo "Checking if only strong SSH Ciphers are used..."
if [ `cat /etc/ssh/sshd_config | grep "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Only strong SSH Ciphers are used"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mOnly strong SSH Ciphers are not used\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure only strong SSH Ciphers to be used
        echo "Configuring only strong SSH Ciphers to be used..."
        sed -i 's/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/ /g' /etc/ssh/sshd_config
        echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
    fi
fi

# Ensure only strong SSH MAC algorithms are used
echo "Checking if only strong SSH MAC algorithms are used..."
if [ `cat /etc/ssh/sshd_config | grep "MACs hmac-sha2-512,hmac-sha2-256" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Only strong SSH MAC algorithms are used"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mOnly strong SSH MAC algorithms are not used\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure only strong SSH MAC algorithms to be used
        echo "Configuring only strong SSH MAC algorithms to be used..."
        sed -i 's/MACs hmac-sha2-512,hmac-sha2-256/ /g' /etc/ssh/sshd_config
        echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
    fi
fi

# Ensure only strong key exchange algorithms are used
echo "Checking if only strong key exchange algorithms are used..."
if [ `cat /etc/ssh/sshd_config | grep "KexAlgorithms" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Only strong key exchange algorithms are used"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mOnly strong key exchange algorithms are not used\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure only strong key exchange algorithms to be used
        echo "Configuring only strong key exchange algorithms to be used..."
        echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchangesha256,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH Idle Timeout Interval is configured
echo "Checking if SSH Idle Timeout Interval is configured..."
if [ `cat /etc/ssh/sshd_config | grep "ClientAliveInterval" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH Idle Timeout Interval is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH Idle Timeout Interval is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH Idle Timeout Interval
        echo "Configuring SSH Idle Timeout Interval..."
        echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH LoginGraceTime is set to one minute or less
echo "Checking if SSH LoginGraceTime is set to one minute or less..."
if [ `cat /etc/ssh/sshd_config | grep "LoginGraceTime 60" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH LoginGraceTime is set to one minute or less"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH LoginGraceTime is not set to one minute or less\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH LoginGraceTime to be set to one minute or less
        echo "Configuring SSH LoginGraceTime to be set to one minute or less..."
        sed -i 's/LoginGraceTime 60/ /g' /etc/ssh/sshd_config
        echo "LoginGraceTime 60" >> /etc/ssh/sshd_config
    fi
fi

# TODO: Ensure SSH access is limited

# Ensure SSH warning banner is configured
echo "Checking if SSH warning banner is configured..."
if [ `cat /etc/ssh/sshd_config | grep "Banner /etc/issue.net" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH warning banner is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH warning banner is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH warning banner
        echo "Configuring SSH warning banner..."
        echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH is configured to usepam
echo "Checking if SSH is configured to usepam..."
if [ `cat /etc/ssh/sshd_config | grep "UsePAM yes" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH is configured to usepam"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH is not configured to usepam\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH to usepam
        echo "Configuring SSH to usepam..."
        sed -i 's/UsePAM yes/ /g' /etc/ssh/sshd_config
        echo "UsePAM yes" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH AllowTCPForwarding is disabled
echo "Checking if SSH AllowTCPForwarding is disabled..."
if [ `cat /etc/ssh/sshd_config | grep "AllowTCPForwarding no" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH AllowTCPForwarding is disabled"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH AllowTCPForwarding is not disabled\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Disable SSH AllowTCPForwarding
        echo "Disabling SSH AllowTCPForwarding..."
        sed -i 's/AllowTCPForwarding no/ /g' /etc/ssh/sshd_config
        echo "AllowTCPForwarding no" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH MaxStartups is configured
echo "Checking if SSH MaxStartups is configured..."
if [ `cat /etc/ssh/sshd_config | grep "MaxStartups 10:30:60" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH MaxStartups is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH MaxStartups is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH MaxStartups
        echo "Configuring SSH MaxStartups..."
        sed -i 's/MaxStartups 10:30:60/ /g' /etc/ssh/sshd_config
        echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config
    fi
fi

# Ensure SSH MaxSessions is configured to 4 or less
echo "Checking if SSH MaxSessions is configured..."
if [ `cat /etc/ssh/sshd_config | grep "MaxSessions 4" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "SSH MaxSessions is configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSSH MaxSessions is not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure SSH MaxSessions
        echo "Configuring SSH MaxSessions..."
        sed -i 's/MaxSessions 4/ /g' /etc/ssh/sshd_config
        echo "MaxSessions 4" >> /etc/ssh/sshd_config
    fi
fi

### PAM Configuration ###
# Ensure lockout for failed password attempts is configured in common-auth
echo "Checking if lockout for failed password attempts is configured in common-auth..."
if [ `cat /etc/pam.d/common-auth | grep "auth required pam_tally2.so deny=5 unlock_time=900" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Lockout for failed password attempts is configured in common-auth"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLockout for failed password attempts is not configured in common-auth\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure lockout for failed password attempts in common-auth
        echo "Configuring lockout for failed password attempts in common-auth..."
        sed -i 's/auth required pam_tally2.so deny=5 unlock_time=900/ /g' /etc/pam.d/common-auth
        echo "auth required pam_tally2.so deny=5 unlock_time=900" >> /etc/pam.d/common-auth
    fi
fi

# Ensure password reuse is limited
echo "Checking if password reuse is limited..."
if [ `cat /etc/pam.d/common-password | grep "password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Password reuse is limited"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPassword reuse is not limited\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure password reuse
        echo "Configuring password reuse..."
        sed -i 's/password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5/ /g' /etc/pam.d/common-password
        echo "password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" >> /etc/pam.d/common-password
    fi
fi

### User Accounts and Environment ###
# Ensure password expiration is 90 days or less
echo "Checking if password expiration is 90 days or less..."
if [ `cat /etc/login.defs | grep "PASS_MAX_DAYS 90" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Password expiration is 90 days or less"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPassword expiration is not 90 days or less\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure password expiration
        echo "Configuring password expiration..."
        sed -i 's/PASS_MAX_DAYS 90/ /g' /etc/login.defs
        echo "PASS_MAX_DAYS 90" >> /etc/login.defs
    fi
fi

# Ensure minimum days between password changes is 1 or more
echo "Checking if minimum days between password changes is 1 or more..."
if [ `cat /etc/login.defs | grep "PASS_MIN_DAYS 1" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Minimum days between password changes is 1 or more"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mMinimum days between password changes is not 1 or more\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure minimum days between password changes
        echo "Configuring minimum days between password changes..."
        sed -i 's/PASS_MIN_DAYS 1/ /g' /etc/login.defs
        echo "PASS_MIN_DAYS 1" >> /etc/login.defs
    fi
fi

# Ensure password expiration warning days is 7 or more
echo "Checking if password expiration warning days is 7 or more..."
if [ `cat /etc/login.defs | grep "PASS_WARN_AGE 7" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Password expiration warning days is 7 or more"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPassword expiration warning days is not 7 or more\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure password expiration warning days
        echo "Configuring password expiration warning days..."
        sed -i 's/PASS_WARN_AGE 7/ /g' /etc/login.defs
        echo "PASS_WARN_AGE 7" >> /etc/login.defs
    fi
fi

# Ensure inactive password lock is 30 days or less
echo "Checking if inactive password lock is 30 days or less..."
if [ `cat /etc/default/useradd | grep "INACTIVE=30" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Inactive password lock is 30 days or less"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mInactive password lock is not 30 days or less\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure inactive password lock
        echo "Configuring inactive password lock..."
        sed -i 's/INACTIVE=30/ /g' /etc/default/useradd
        echo "INACTIVE=30" >> /etc/default/useradd
    fi
fi

# Ensure password hashing algorithm is SHA-512
echo "Checking if password hashing algorithm is SHA-512..."
if [ `cat /etc/pam.d/common-password | grep "password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Password hashing algorithm is SHA-512"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPassword hashing algorithm is not SHA-512\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure password hashing algorithm
        echo "Configuring password hashing algorithm..."
        sed -i 's/password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5/ /g' /etc/pam.d/common-password
        echo "password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" >> /etc/pam.d/common-password
    fi
fi

# Ensure all users last password change date is in the past
echo "Checking if all users last password change date is in the past..."
if [ `cat /etc/shadow | grep -v "!!" | awk -F: '{print $3}' | grep -v "0" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "All users last password change date is in the past"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mAll users last password change date is not in the past\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure all users last password change date
        echo "Configuring all users last password change date..."
        for user in `cat /etc/shadow | grep -v "!!" | awk -F: '{print $1}'`; do
            chage -d 0 $user
        done
    fi
fi

# Ensure system accounts (root, sync, shutdown, and halt) are secured
echo "Checking if system accounts (root, sync, shutdown, and halt) are secured..."
if [ `cat /etc/shadow | grep -v "!!" | awk -F: '{print $1}' | grep -E "root|sync|shutdown|halt" | wc -l` -eq 4 ]; then
    # Do nothing
    echo "System accounts (root, sync, shutdown, and halt) are secured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mSystem accounts (root, sync, shutdown, and halt) are not secured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure system accounts
        echo "Configuring system accounts..."
        for user in `cat /etc/shadow | grep -v "!!" | awk -F: '{print $1}' | grep -E "root|sync|shutdown|halt"`; do
            chage -d 0 $user
        done
    fi
fi

# Ensure default group for the root account is GID 0
echo "Checking if default group for the root account is GID 0..."
if [ `cat /etc/passwd | grep "root" | awk -F: '{print $4}' | grep "0" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Default group for the root account is GID 0"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDefault group for the root account is not GID 0\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure default group for the root account
        echo "Configuring default group for the root account..."
        usermod -g 0 root
    fi
fi

# Ensure default user umask is 027 or more restrictive
echo "Checking if default user umask is 027 or more restrictive..."
if [ `cat /etc/bashrc | grep "umask 027" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Default user umask is 027 or more restrictive"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDefault user umask is not 027 or more restrictive\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure default user umask
        echo "Configuring default user umask..."
        sed -i 's/umask 027/ /g' /etc/bashrc
        echo "umask 027" >> /etc/bashrc
        # Edit /etc/profile
        sed -i 's/umask 027/ /g' /etc/profile
        echo "umask 027" >> /etc/profile
        # Edit /etc/profile.d/*.sh
        for file in `ls /etc/profile.d/*.sh`; do
            sed -i 's/umask 027/ /g' $file
            echo "umask 027" >> $file
        done
    fi
fi

# Ensure default user shell timeout is 900 seconds or less
echo "Checking if default user shell timeout is 900 seconds or less..."
if [ `cat /etc/profile | grep "TMOUT=900" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Default user shell timeout is 900 seconds or less"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDefault user shell timeout is not 900 seconds or less\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure default user shell timeout
        echo "Configuring default user shell timeout..."
        sed -i 's/TMOUT=900/ /g' /etc/profile
        echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile
    fi
fi

# Ensure access to the su commands is restricted
echo "Checking if access to the su commands is restricted..."
if [ `cat /etc/pam.d/su | grep "auth required pam_wheel.so use_uid" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Access to the su commands is restricted"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mAccess to the su commands is not restricted\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Add sudo group
        groupadd sugroup
        # Configure access to the su commands
        echo "Configuring access to the su commands..."
        sed -i 's/auth required pam_wheel.so use_uid/ /g' /etc/pam.d/su
        echo "auth required pam_wheel.so use_uid group=sugroup" >> /etc/pam.d/su
    fi
fi

### System Maintenance ###
# Ensure permissions on /etc/passwd are configured
echo "Checking if permissions on /etc/passwd are configured..."
if [ `ls -l /etc/passwd | awk '{print $1}' | grep "-rw-r--r--" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/passwd are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/passwd are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/passwd
        echo "Configuring permissions on /etc/passwd..."
        chown root:root /etc/passwd
        chmod 644 /etc/passwd
    fi
fi

# Ensure permissions on /etc/gshadow- are configured
echo "Checking if permissions on /etc/gshadow- are configured..."
if [ `ls -l /etc/gshadow- | awk '{print $1}' | grep "-rw-r-----" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/gshadow- are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/gshadow- are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/gshadow
        echo "Configuring permissions on /etc/gshadow..."
        chown root:shadow /etc/gshadow-
        chmod g-wx,o-rwx /etc/gshadow-
    fi
fi

# Ensure permissions on /etc/shadow are configured
echo "Checking if permissions on /etc/shadow are configured..."
if [ `ls -l /etc/shadow | awk '{print $1}' | grep "-rw-r-----" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/shadow are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/shadow are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/shadow
        echo "Configuring permissions on /etc/shadow..."
        chown root:shadow /etc/shadow
        chmod g-wx,o-rwx /etc/shadow
    fi
fi

# Ensure permissions on /etc/group are configured
echo "Checking if permissions on /etc/group are configured..."
if [ `ls -l /etc/group | awk '{print $1}' | grep "-rw-r--r--" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/group are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/group are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/group
        echo "Configuring permissions on /etc/group..."
        chown root:root /etc/group
        chmod 644 /etc/group
    fi
fi

# Ensure permissions on /etc/passwd- are configured
echo "Checking if permissions on /etc/passwd- are configured..."
if [ `ls -l /etc/passwd- | awk '{print $1}' | grep "-rw-------" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/passwd- are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/passwd- are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/passwd-
        echo "Configuring permissions on /etc/passwd-..."
        chown root:root /etc/passwd-
        chmod 600 /etc/passwd-
    fi
fi

# Ensure permissions on /etc/shadow- are configured
echo "Checking if permissions on /etc/shadow- are configured..."
if [ `ls -l /etc/shadow- | awk '{print $1}' | grep "-rw-------" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/shadow- are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/shadow- are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/shadow-
        echo "Configuring permissions on /etc/shadow-..."
        chown root:root /etc/shadow-
        chmod 600 /etc/shadow-
    fi
fi

# Ensure permissions on /etc/group- are configured
echo "Checking if permissions on /etc/group- are configured..."
if [ `ls -l /etc/group- | awk '{print $1}' | grep "-rw-------" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/group- are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/group- are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/group-
        echo "Configuring permissions on /etc/group-..."
        chown root:root /etc/group-
        chmod 600 /etc/group-
    fi
fi

# Ensure permissions on /etc/gshadow are configured
echo "Checking if permissions on /etc/gshadow are configured..."
if [ `ls -l /etc/gshadow | awk '{print $1}' | grep "-rw-r-----" | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Permissions on /etc/gshadow are configured"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPermissions on /etc/gshadow are not configured\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Configure permissions on /etc/gshadow
        echo "Configuring permissions on /etc/gshadow..."
        chown root:shadow /etc/gshadow
        chmod g-wx,o-rwx /etc/gshadow
    fi
fi

# Ensure no world writable files exist
echo "Checking if there are any world writable files..."
if [ `find / -xdev -type f -perm -0002 | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No world writable files"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mWorld writable files detected\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all world writable files
        echo "Fixing world writable files..."
        find / -xdev -type f -perm -0002 -exec chmod o-w {} \;
    fi
fi

# Ensure no unowned files or directories exist
echo "Checking if there are any unowned files or directories..."
if [ `find / -xdev -nouser -o -nogroup | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No unowned files or directories"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUnowned files or directories detected\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all unowned files and directories
        echo "Fixing unowned files and directories..."
        # Auto reset ownership to root
        find / -xdev -nouser -exec chown root {} \;
        find / -xdev -nogroup -exec chgrp root {} \;
    fi
fi

### Users and Groups Settings ###
# Ensure password fields are not empty
echo "Checking if password fields are not empty..."
if [ `awk -F: '($2 == "") { print $1 }' /etc/shadow | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Password fields are not empty"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mPassword fields are empty\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all empty password fields
        echo "Fixing empty password fields..."
        # Auto reset password to "password"
        awk -F: '($2 == "") { print $1 }' /etc/shadow | xargs -I {} passwd -d {}
    fi
fi

# Ensure no legacy "+" entries exist in /etc/passwd
echo "Checking if there are any legacy '+' entries in /etc/passwd..."
if [ `grep -v -E "^#" /etc/passwd | awk -F: '($3 == "+") { print $1 }' | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No legacy '+' entries in /etc/passwd"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLegacy '+' entries detected in /etc/passwd\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all legacy '+' entries
        echo "Fixing legacy '+' entries..."
        # Remove legacy '+' entries
        grep -v -E "^#" /etc/passwd | awk -F: '($3 == "+") { print $1 }' | xargs -I {} userdel {}
    fi
fi

# Ensure all users home directories exist
echo "Checking if all users home directories exist..."
if [ `cat /etc/passwd | cut -d: -f6 | xargs -I {} ls -d {} 2>/dev/null | wc -l` -eq `cat /etc/passwd | cut -d: -f6 | wc -l` ]; then
    # Do nothing
    echo "All users home directories exist"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers home directories do not exist\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users home directories that do not exist
        echo "Fixing users home directories..."
        # Log users who do not have home directories in blue
        echo -e "\e[34m`cat /etc/passwd | cut -d: -f6 | xargs -I {} ls -d {} 2>/dev/null | wc -l` users have home directories\e[0m"
        # Auto create home directories
        cat /etc/passwd | cut -d: -f6 | xargs -I {} mkdir -p {}
    fi
fi

# Ensure no legacy "+" entries exist in /etc/shadow
echo "Checking if there are any legacy '+' entries in /etc/shadow..."
if [ `grep -v -E "^#" /etc/shadow | awk -F: '($3 == "+") { print $1 }' | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No legacy '+' entries in /etc/shadow"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLegacy '+' entries detected in /etc/shadow\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all legacy '+' entries
        echo "Fixing legacy '+' entries..."
        # Remove legacy '+' entries
        grep -v -E "^#" /etc/shadow | awk -F: '($3 == "+") { print $1 }' | xargs -I {} usermod -U {}
    fi
fi

# Ensure no legacy "+" entries exist in /etc/group
echo "Checking if there are any legacy '+' entries in /etc/group..."
if [ `grep -v -E "^#" /etc/group | awk -F: '($3 == "+") { print $1 }' | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No legacy '+' entries in /etc/group"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mLegacy '+' entries detected in /etc/group\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all legacy '+' entries
        echo "Fixing legacy '+' entries..."
        # Remove legacy '+' entries
        grep -v -E "^#" /etc/group | awk -F: '($3 == "+") { print $1 }' | xargs -I {} groupdel {}
    fi
fi

# Ensure root is the only UID 0 account
echo "Checking if root is the only UID 0 account..."
if [ `awk -F: '($3 == 0) { print $1 }' /etc/passwd | wc -l` -eq 1 ]; then
    # Do nothing
    echo "Root is the only UID 0 account"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mRoot is not the only UID 0 account\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all UID 0 accounts
        echo "Fixing UID 0 accounts..."
        # Remove all UID 0 accounts except root
        awk -F: '($3 == 0) { print $1 }' /etc/passwd | grep -v "root" | xargs -I {} userdel {}
    fi
fi

# TODO: Ensure root PATH Integrity

# Ensure users' home directories permissions are 750 or more restrictive
echo "Checking if users' home directories permissions are 750 or more restrictive..."
if [ `find /home -maxdepth 1 -type d -perm /027 -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Users' home directories permissions are 750 or more restrictive"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers' home directories permissions are not 750 or more restrictive\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users' home directories permissions that are not 750 or more restrictive
        echo "Fixing users' home directories permissions..."
        # Log users who do not have home directories permissions that are 750 or more restrictive in blue
        echo -e "\e[34m`find /home -maxdepth 1 -type d -perm /027 -ls | wc -l` users have home directories permissions that are 750 or more restrictive\e[0m"
        # Auto fix users' home directories permissions
        find /home -maxdepth 1 -type d -perm /027 -ls | awk '{print $11}' | xargs -I {} chmod 750 {}
    fi
fi

# Ensure users own their home directories
echo "Checking if users own their home directories..."
if [ `find /home -maxdepth 1 -type d -not -user root -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Users own their home directories"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers do not own their home directories\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users who do not own their home directories
        echo "Fixing users who do not own their home directories..."
        # Log users who do not own their home directories in blue
        echo -e "\e[34m`find /home -maxdepth 1 -type d -not -user root -ls | wc -l` users do not own their home directories\e[0m"
        # Auto fix users who do not own their home directories
        find /home -maxdepth 1 -type d -not -user root -ls | awk '{print $11}' | xargs -I {} chown root {}
    fi
fi

# Ensure users dot files are not group or world writable
echo "Checking if users dot files are not group or world writable..."
if [ `find /home -maxdepth 2 -type f -perm /002 -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Users dot files are not group or world writable"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers dot files are group or world writable\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users dot files that are group or world writable
        echo "Fixing users dot files that are group or world writable..."
        # Log users who have dot files that are group or world writable in blue
        echo -e "\e[34m`find /home -maxdepth 2 -type f -perm /002 -ls | wc -l` users have dot files that are group or world writable\e[0m"
        # Auto fix users dot files that are group or world writable
        find /home -maxdepth 2 -type f -perm /002 -ls | awk '{print $11}' | xargs -I {} chmod 600 {}
    fi
fi

# Ensure no users have .forward files
echo "Checking if there are any users with .forward files..."
if [ `find /home -maxdepth 2 -type f -name ".forward" -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No users have .forward files"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers have .forward files\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users who have .forward files
        echo "Fixing users who have .forward files..."
        # Log users who have .forward files in blue
        echo -e "\e[34m`find /home -maxdepth 2 -type f -name ".forward" -ls | wc -l` users have .forward files\e[0m"
        # Auto fix users who have .forward files
        find /home -maxdepth 2 -type f -name ".forward" -ls | awk '{print $11}' | xargs -I {} rm {}
    fi
fi

# Ensure no users have .netrc files
echo "Checking if there are any users with .netrc files..."
if [ `find /home -maxdepth 2 -type f -name ".netrc" -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No users have .netrc files"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers have .netrc files\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users who have .netrc files
        echo "Fixing users who have .netrc files..."
        # Log users who have .netrc files in blue
        echo -e "\e[34m`find /home -maxdepth 2 -type f -name ".netrc" -ls | wc -l` users have .netrc files\e[0m"
        # Auto fix users who have .netrc files
        find /home -maxdepth 2 -type f -name ".netrc" -ls | awk '{print $11}' | xargs -I {} rm {}
    fi
fi

# Ensure users .netrc Files are not group or world accessible
echo "Checking if users .netrc files are not group or world accessible..."
if [ `find /home -maxdepth 2 -type f -name ".netrc" -perm /077 -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "Users .netrc files are not group or world accessible"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers .netrc files are group or world accessible\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users .netrc files that are group or world accessible
        echo "Fixing users .netrc files that are group or world accessible..."
        # Log users who have .netrc files that are group or world accessible in blue
        echo -e "\e[34m`find /home -maxdepth 2 -type f -name ".netrc" -perm /077 -ls | wc -l` users have .netrc files that are group or world accessible\e[0m"
        # Auto fix users .netrc files that are group or world accessible
        find /home -maxdepth 2 -type f -name ".netrc" -perm /077 -ls | awk '{print $11}' | xargs -I {} chmod 600 {}
    fi
fi

# Ensure no users have .rhosts files
echo "Checking if there are any users with .rhosts files..."
if [ `find /home -maxdepth 2 -type f -name ".rhosts" -ls | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No users have .rhosts files"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mUsers have .rhosts files\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users who have .rhosts files
        echo "Fixing users who have .rhosts files..."
        # Log users who have .rhosts files in blue
        echo -e "\e[34m`find /home -maxdepth 2 -type f -name ".rhosts" -ls | wc -l` users have .rhosts files\e[0m"
        # Auto fix users who have .rhosts files
        find /home -maxdepth 2 -type f -name ".rhosts" -ls | awk '{print $11}' | xargs -I {} rm {}
    fi
fi

# TODO: Ensure all groups in /etc/passwd exist in /etc/group

# Ensure no duplicate UIDs exist
echo "Checking if there are any duplicate UIDs..."
if [ `cut -f3 -d: /etc/passwd | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No duplicate UIDs exist"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDuplicate UIDs exist\e[0m"
    # Log all duplicate UIDs in blue
    echo -e "\e[34m`cut -f3 -d: /etc/passwd | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` duplicate UIDs exist\e[0m"
fi

# Ensure no duplicate GIDs exist
echo "Checking if there are any duplicate GIDs..."
if [ `cut -f3 -d: /etc/group | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No duplicate GIDs exist"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDuplicate GIDs exist\e[0m"
    # Log all duplicate GIDs in blue
    echo -e "\e[34m`cut -f3 -d: /etc/group | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` duplicate GIDs exist\e[0m"
fi

# Ensure no duplicate user names exist
echo "Checking if there are any duplicate user names..."
if [ `cut -f1 -d: /etc/passwd | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No duplicate user names exist"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDuplicate user names exist\e[0m"
    # Log all duplicate user names in blue
    echo -e "\e[34m`cut -f1 -d: /etc/passwd | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` duplicate user names exist\e[0m"
fi

# Ensure no duplicate group names exist
echo "Checking if there are any duplicate group names..."
if [ `cut -f1 -d: /etc/group | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` -eq 0 ]; then
    # Do nothing
    echo "No duplicate group names exist"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mDuplicate group names exist\e[0m"
    # Log all duplicate group names in blue
    echo -e "\e[34m`cut -f1 -d: /etc/group | sort -n | uniq -c | awk '{print $1}' | grep -v "^1$" | wc -l` duplicate group names exist\e[0m"
fi

# Ensure shadow group is empty
echo "Checking if the shadow group is empty..."
if [ `grep ^shadow /etc/group | cut -f4 -d:` = "" ]; then
    # Do nothing
    echo "The shadow group is empty"
else
    # Increment detection counter
    detection_counter=$((detection_counter+1))
    # Log the detection in red
    echo -e "\e[31mThe shadow group is not empty\e[0m"
    # If modifications are allowed, fix the issue
    if [ $allow_modifications -eq 1 ]; then
        # Find all users who are in the shadow group
        echo "Fixing users who are in the shadow group..."
        # Log users who are in the shadow group in blue
        echo -e "\e[34m`grep ^shadow /etc/group | cut -f4 -d:` users are in the shadow group\e[0m"
        # Auto fix users who are in the shadow group
        for user in `grep ^shadow /etc/group | cut -f4 -d:`; do
            gpasswd -d $user shadow
        done
    fi
fi

# Finalize the script
# Check if there were any detections
if [ $detection_counter -eq 0 ]; then
    # Do nothing
    echo "No detections"
else
    # Print the detections
    echo "Detections: $detection_counter"
fi
