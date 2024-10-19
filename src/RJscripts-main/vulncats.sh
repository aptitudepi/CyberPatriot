#!/bin/bash
###to do: make menu for script to run
chmod +x logo
./logo
echo -n """
WELCOME TO RISHABH'S MONSTER SCRIPT
MAKE SURE YOU KNOW WHAT VERSION/FLAVOR OF LINUX YOU ARE ON!!!!!
WHAT WOULD YOU LIKE TO DO?
1. Account + Local Policy - PAM --> (NO PAM IS CONFIGURED HERE) (vulncats too confusing so just bear with this)
2. Application Security Settings + firefox security (critical services --> work in progress)
3. Operating System + Application Updates (NEED TO ADD KERNEL UPDATE!!! MISSING!!!)
4. Defensive Countermeasures
5. Malware (recon goes brr)
6. Prohibited Files
7. Unwanted Software (run this before 6)
8. Service Auditing (sysctl.sh also takes care of some, so run before this)
9. Uncategorized Operating System Settings (+ kernel hardening)
10. User Auditing
11. PAM :skull:
12. Grub
"""
read -p "Enter your choice: " scriptmenu
if [[ $scriptmenu = "1" ]]; then
#/etc/login.defs
mv /etc/login.defs /etc/login.defs.bak
mv ~/pre-configured-files/login.defs /etc/login.defs
chmod 644 /etc/login.defs
#/etc/sysctl.conf
echo "hardening sysctl"
./sysctl.sh
mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm/conf.bak
mv ~/pre-configured-files/lightdm.conf /etc/lightdm/lightdm.conf
#dconf stuff
dconf reset -f /
gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.media-handling automount false
gsettings set org.gnome.desktop.media-handling automount-open false
gsettings set org.gnome.desktop.search-providers disable-external true
dconf update /
echo "enter the main user of this system (readme)"
read user
#screen timeout policy
sudo -u $user gsettings set org.gnome.desktop.session idle-delay 300
#auto screen lock
sudo -u $user gsettings set org.gnome.desktop.screensaver lock-enabled true
fi
if [[ $scriptmenu = "2" ]]; then
echo "this hardens nginx, php, apache, mysql, firefox"
sleep 3
./nginx.sh
./firefox.sh
apt install --reinstall php -y
for i in $(find / -name php.ini | xargs);
do 
  mv $i $i.bak;
  cp ~/pre-configured-files/php.ini $i;
done
echo -n "Do you want to configure MySQL? [Y/n]"
read option
if [[ $option =~ ^[Yy]$ ]]
then
	# Install MySQL Server and Client 
	sudo apt-get install mysql-server mysql-client -y 
	# Secure MySQL Installation
	sudo mysql_secure_installation
	sudo service mysql stop
	sudo mysqld_safe --skip_networking=0
	sudo mysql --skip-networking=OFF
	sudo service mysql start
	# Set root password
	echo -n "Do you want to set the root password to "SuP3rs3CurEmYsQL!" ?"
	read mysqlrootpass
	if [[ $mysqlrootpass =~ ^[Yy]$ ]]
	then
		sudo mysqladmin -u root password 'SuP3rs3CurEmYsQL!'
		sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'SuP3rs3CurEmYsQL!';"
	fi
	
	# Create a new user 
	#sudo mysql -u root -p  << EOF 
	#CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
	#GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost';
	#FLUSH PRIVILEGES;
	#EOF
	echo -n "Do you want to change password policies for mysql?"
	read mysqlpasspol
	if 
	then
		# Set the default storage engine to InnoDB
		sudo mysql -e "SET GLOBAL storage_engine=INNODB;"

		# Set the default password policy
		sudo mysql -e "SET GLOBAL validate_password_policy=MEDIUM;"

		# Set the default password length
		sudo mysql -e "SET GLOBAL validate_password_length=14;"

		# Set the default password complexity
		sudo mysql -e "SET GLOBAL validate_password_mixed_case_count=1;"

		# Set the default password number of digits
		sudo mysql -e "SET GLOBAL validate_password_number_count=1;"

		# Set the default password special characters
		sudo mysql -e "SET GLOBAL validate_password_special_char_count=1;"

		# Set the default password history
		sudo mysql -e "SET GLOBAL validate_password_history=1;"

		# Set the default password lifetime
		sudo mysql -e "SET GLOBAL validate_password_lifetime=365;"

		# Set the default password reuse interval
		sudo mysql -e "SET GLOBAL validate_password_reuse_interval=365;"
	fi
	# Configure MySQL 
	sudo sed -i "s/.*bind-address.*/bind-address = 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i "s/.*skip-external-locking.*/skip-external-locking/" /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i "s/.*sql_mode.*/sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION/" /etc/mysql/mysql.conf.d/mysqld.cnf

	# Restart MySQL 
	sudo systemctl restart mysql

	# Enable Firewall 
	sudo ufw enable 
	sudo ufw allow 3306/tcp

	# Enable MySQL Logging 
	sudo sed -i "s/.*log_error.*/log_error = \/var\/log\/mysql\/error.log/" /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i "s/.*general_log.*/general_log = 1/" /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i "s/.*general_log_file.*/general_log_file = \/var\/log\/mysql\/general.log/" /etc/mysql/mysql.conf.d/mysqld.cnf

	# Restart MySQL 
	sudo systemctl restart mysql

	# Create Log Directory 
	sudo mkdir /var/log/mysql
	sudo chown mysql:mysql /var/log/mysql

	echo "MySQL has been successfully hardened!" >> ~/script.log
else
	sudo apt-get autoremove --purge mysql -y
fi
#end
echo -n "Do you want to configure PHP7.0? [Y/n]"
read option
if [[ $option =~ ^[Yy]$ ]]
then
	#echo "make sure that under the disable_functions section in the /etc/php/7.x/php.ini, shell_exec is added to the list" > ~/DOTHISFORPHP.txt
	# Install the necessary packages for PHP7 and security hardening
	#sudo apt-get install php7.0 php7.0-cli php7.0-common libapache2-mod-php7.0 -y
	#sudo apt-get install libapache2-modsecurity -y
	for ini in $(find / -name "php.ini" 2>/dev/null); do
		cat ~/pre-configured-files/php.ini > $ini
	done
	# Configure the PHP settings for security hardening
	sudo sed -i 's/expose_php = On/expose_php = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/allow_url_include = On/allow_url_include = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/display_errors = On/display_errors = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/log_errors = Off/log_errors = On/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/register_globals = On/register_globals = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/magic_quotes_gpc = On/magic_quotes_gpc = Off/g' /etc/php/7.0/apache2/php.ini
	sudo sed -i 's/session.cookie_httponly = Off/session.cookie_httponly = On/g' /etc/php/7.0/apache2/php.ini
	#echo "php7.0 configured" >> ~/script.log
fi

fi
if [[ $scriptmenu = "3" ]]; then
echo "sources.list.d"
ls -la /etc/apt/sources.list.d
sleep 10
echo "apt.conf.d"
ls -la /etc/apt/apt.conf.d
sleep 10
echo "do software & updates as well as synaptic if debian"
sleep 2
./updates.sh
echo "apt install --reinstall critical services after making file backups"
fi
if [[ $scriptmenu = "4" ]]; then
./ufw.sh
fi
if [[ $scriptmenu = "5" ]]; then
echo "run funny recon scripts"
echo "Installing and running debsums (this may take a while, so feel free to do forensics in the background)"
sleep 2
apt install debsums -y
debsums -ca > ~/debsums.txt
echo "Installing and running rkhunter"
sleep 2
apt install rkhunter -y
rkhunter -c
echo "running rkhunter scan 2"
rkhunter --checkall --sk
echo "installing and running linpeas"
sleep 2
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
echo "installing and running lynis"
sleep 2
cd ~
touch lynis.txt
touch lynisaudit.txt
wget https://cisofy.com/files/lynis-3.0.6.tar.gz -O /lynis.tar.gz
tar -xvzf /lynis.tar.gz --directory /usr/share/
cd /usr/share/lynis/
/usr/share/lynis/lynis update info
/usr/share/lynis/lynis audit system
sudo lynis -c -Q >> lynis.txt
sudo lynis audit system >> lynisaudit.txt
echo "Installing and running chkrootkit"
sleep 2
apt install chkrootkit
chkrootkit -x
echo "Installing and running blue team scripts"
bash blueteam/audit.sh
echo "need to test audit2.sh"
echo "finding kernel modules (diff this with clean image)"
find /lib/modules/$(uname -r) -type f -name '*.ko' > ~/kernelmods.txt
echo "finding kernel modules"
find /usr/lib/modules/ -name *.ko > ~/kernelmodules.txt
sleep 1
echo "installing clamtk"
sudo apt-get install clamtk -y
clamtk
fi
if [[ $scriptmenu = "6" ]]; then
echo "finding and reporting PII"
./find_personal_info.sh
fi
if [[ $scriptmenu = "7" ]]; then
./packagemgmt.sh
fi
if [[ $scriptmenu = "8" ]]; then
systemctl disable cups.service
apt install apparmor -y
systemctl enable apparmor
systemctl enable rsyslog
#systemctl unnecessary services
systemctl disable cups-browsed
systemctl disable avahi-daemon
systemctl stop cups-browsed
systemctl stop avahi-daemon
fi
if [[ $scriptmenu = "9" ]]; then
echo "if internet is broken, fix it"
sleep 2
nano /etc/resolv.conf
echo "LLMNR=no"
sleep 2
nano /etc/systemd/resolved.conf
echo "doing more kernel hardening"
./kernelrunfirst.sh
./grubanddev.sh
./kernel.sh
fi
if [[ $scriptmenu = "10" ]]; then
echo "Running user script"
sleep 1
./usermgmt.sh
echo "check for bad shells, hidden users, incorrect uids, etc."
sleep 2
nano /etc/passwd
echo "check groups -- esp admins"
sleep 2
nano /etc/group
echo "check for bad hash types in shadow or locked/disabled users"
sleep 2
nano /etc/shadow
passwd -l root
echo "login.defs is in policy script. You should run that."
echo "fixing and reporting .bashrc's and .profile's"
for i in $(find / -name .bashrc | xargs);
do 
  mv $i ~/$i.bak;
  cp ~/pre-configured-files/.bashrc $i;
done
for i in $(find / -name .profile | xargs);
do 
  mv $i ~/$i.bak;
  cp ~/pre-configured-files/.profile $i;
done
fi
if [[ $scriptmenu = "11" ]]; then
echo "run this ONLY AFTER #1!"
sleep 5
./pam.sh
echo "double checking configs"
./password_policy_checks.sh
fi
if [[ $scriptmenu = "12" ]]; then
./grubanddev.sh
fi
