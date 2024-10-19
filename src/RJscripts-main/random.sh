#!/bin/bash
#Install and configure a host-based intrusion detection system (HIDS) such as OSSEC or tripwire:
sudo apt install libpam-google-authenticator -y
sudo google-authenticator
#Enable apparmor to restrict application access to system resources:
sudo apt install apparmor -y
sudo aa-status
sudo apt install apparmor-profiles -y
##Implement network security measures such as TLS encryption and strict access control policies:
#Use TLS encryption for web services such as HTTPS and SSH:
sudo apt install certbot
sudo certbot --nginx
#Disable unused network protocols and services:
sudo apt install net-tools
sudo sed -i 's/\(ENABLED=\).*/\10/g' /etc/default/isc-dhcp-server
sudo systemctl stop isc-dhcp-server.service
sudo systemctl disable isc-dhcp-server.service
sudo sed -i 's/#\?\(Port\s\+\)\(.*\)/\1 22/g' /etc/ssh/sshd_config
sudo sed -i 's/#\?\(PermitRootLogin\s\+\)\(.*\)/\1 no/g' /etc/ssh/sshd_config
sudo sed -i 's/#\?\(Protocol\s\+\)\(.*\)/\1 2/g' /etc/ssh/sshd_config
#auditd grub
sudo apt install auditd
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="audit=1 /g' /etc/default/grub
sudo update-grub
#enable SELinux
sudo apt install selinux-utils
sudo selinux-activate
#not too sure if cypat likes hardened kernels
#sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 8B48AD6246925553
#sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 7638D0442B90D010
#sudo apt-get update
#sudo apt-get install linux-image-grsec
#PAM
sudo apt install libpam-pwquality
sudo sed -i 's/#\?password\s*requisite\s*pam_pwquality\.so.*/password requisite pam_pwquality.so retry=3 enforce_for_root minlen=12 ucredit=-1 dcredit=-1 ocredit=-1 lcredit=-1 difok=3 reject_username enforce_for_root/g' /etc/pam.d/common-password
sudo sed -i 's/auth\s*required\s*pam_loginuid\.so/auth required pam_loginuid.so\nauth required pam_tally2.so deny=5 unlock_time=900\nauth required pam_env.so\nauth required pam_tally2.so onerr=fail/g' /etc/pam.d/common-auth
sudo sed -i 's/session\s*required\s*pam_loginuid\.so/session required pam_loginuid.so\nsession required pam_limits.so\nsession optional pam_umask.so/g' /etc/pam.d/common-session
# Create a strong password that satisfies PAM reqs
password=$(openssl rand -base64 16)
echo "Your new password is: $password"
echo "PLEASE SAVE THIS PASS!!!."
sleep 5
echo "CHANGING CURRENT USER'S PASS!!! CTRL+C TO ABORT! ..."
sleep 5
echo "$password" | passwd --stdin $(whoami)
