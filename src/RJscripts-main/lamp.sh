#!/bin/bash

#samba configs
echo -n "Should Samba be on this system? [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo ufw allow samba
  pdbedit -L > ~/sambausers.txt
  echo "
  smbpasswd -x user (to remove user) 
  smbpasswd -a user (to add user or change existing user password)
  " >> ~/sambainstructions.txt
  chattr -R -i /etc/samba/*
  apt-get install samba  -y
  echo -n "Enter the name of the share to create for sambashare (check README)"
  read sharename
  echo "[$sharename]" >> /etc/samba/smb.conf
  echo """
    comment = Samba on Ubuntu
    path = /mnt/sambashare
    browseable = yes
    read only = yes
    create mask = 0600
    guest ok = no
    encrypt passwords = yes
  """ >> /etc/samba/smb.conf
  testparm
  sudo service smbd restart
  echo "Type all users to add to sambashare with a space in between"
  read -a sambausers
  usersLen=${#sambausers[@]}	
  for (( i=0;i<$usersLen;i++))
  do
  	#echo "	valid users = ${sambausers[${i}]}" >> /etc/samba/smb.conf
  	sudo smbpasswd -a ${sambausers[${i}]}
  	sudo smbpasswd -e ${sambausers[${i}]}
  done
  sed -i 's/^interfaces.*/interfaces = eth* lo' /etc/samba/smb.conf || echo 'interfaces = eth* lo' >> /etc/samba/smb.conf
  sed -i 's/^bind interfaces only.*/bind interfaces only/' /etc/samba/smb.conf || echo 'bind interfaces only' >> /etc/samba/smb.conf
  sed -i 's/^restrict anonymous.*/restrict anonymous = 2/' /etc/samba/smb.conf || echo 'restrict anonymous = 2' >> /etc/samba/smb.conf
  sed -i 's/^encrypt passwords.*/encrypt passwords = yes/' /etc/samba/smb.conf || echo 'encrypt passwords = yes' >> /etc/samba/smb.conf
  sudo ufw allow samba
  cd ~
  touch samba.txt
  testparm >> samba.txt
  sudo service smbd restart
  clear
  echo "Samba configured. Please delete it if not needed" >> ~/script.log
else
  sudo apt-get autoremove --purge sambashare
fi
pdbedit -L > ~/sambausers.txt
#postfix configs
echo -n "Should Postfix be on this system? [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo apt install postfix -y
  chattr -R -i /etc/postfix/*
  sudo chmod 755 /etc/postfix
  sudo chmod 644 /etc/postfix/*.cf
  sudo chmod 755 /etc/postfix/postfix-script*
  sudo chmod 755 /var/spool/postfix
  sudo chown root:root /var/log/mail*
  sudo chmod 600 /var/log/mail*
  postconf -e disable_vrfy_command=yes #Disable verify
  postconf -e inet_interfaces=loopback-only #Have postfix listen only on the local interface. Change only if the server is just used to relay messages.
  postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128" #Only forward mail on the local network
  postconf -e smtpd_helo_required=yes #Enable HELO, which is pretty much the mail server “greeter”
  echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
  echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
  echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd" >> /etc/postfix/main.cf
  sed -i 's/^inet_interfaces.*/inet_interfaces = localhost/' /etc/postfix/main.cf || echo 'inet_interfaces = localhost' >> /etc/postfix/main.cf
  sed -i 's/^default_process_limit.*/default_process_limit = 100/' /etc/postfix/main.cf || echo 'default_process_limit = 100' >> /etc/postfix/main.cf
  sed -i 's/^smtpd_client_connection_count_limit.*/smtpd_client_connection_count_limit = 10/' /etc/postfix/main.cf || echo 'smtpd_client_connection_count_limit = 10' >> /etc/postfix/main.cf
  sed -i 's/^smtpd_client_connection_rate_limit.*/smtpd_client_connection_rate_limit = 30/' /etc/postfix/main.cf || echo 'smtpd_client_connection_rate_limit = 30' >> /etc/postfix/main.cf
  sed -i 's/^.queue_minfree*/queue_minfree = 20971520/' /etc/postfix/main.cf || echo 'queue_minfree = 20971520' >> /etc/postfix/main.cf
  sed -i 's/^header_size_limit.*/header_size_limit = 51200/' /etc/postfix/main.cf || echo 'header_size_limit = 51200' >> /etc/postfix/main.cf
  sed -i 's/^message_size_limit.*/message_size_limit = 10485760/' /etc/postfix/main.cf || echo 'message_size_limit = 10485760' >> /etc/postfix/main.cf
  sed -i 's/^smtpd_recipient_limit.*/smtpd_recipient_limit = 100/' /etc/postfix/main.cf || echo 'smtpd_recipient_limit = 100' >> /etc/postfix/main.cf
  sed -i 's/^disable_vrfy_command.*/disable_vrfy_command = yes/' /etc/postfix/main.cf || echo 'disable_vrfy_command = yes' >> /etc/postfix/main.cf
  sed -i 's/^smtpd_delay_reject.*/smtpd_delay_reject = yes/' /etc/postfix/main.cf || echo 'smtpd_delay_reject = yes' >> /etc/postfix/main.cf
  sed -i 's/^smtpd_helo_required.*/smtpd_helo_required = yes/' /etc/postfix/main.cf || echo 'smtpd_helo_required = yes' >> /etc/postfix/main.cf
  sed -i 's/^.*//' /etc/postfix/main.cf || echo '' >> /etc/postfix/main.cf
  sed -i 's/^.*//' /etc/postfix/main.cf || echo '' >> /etc/postfix/main.cf
  sed -i 's/^.*//' /etc/postfix/main.cf || echo '' >> /etc/postfix/main.cf
  sed -i 's/^.*//' /etc/postfix/main.cf || echo '' >> /etc/postfix/main.cf
  postconf -e smtp_tls_loglevel=1
  cd ~
  touch postfixstuff.txt
  echo "#This command should give two lines of output. The first is the temporary key, which should be at least 1024 bits. The second is the public key, which should be greater than or equal to 2048 bits."
  echo | openssl s_client -starttls smtp -connect localhost:25 -cipher "EDH" 2>/dev/null | grep -i -e "Server .* key" >> postfixstuff.txt
  sudo systemctl restart postfix
  sudo ufw allow Postfix
  echo "Postfix configured. Please delete if not needed." >> ~/script.log
else
  sudo apt-get autoremove --purge postfix* -y
fi

#mariadb configs
echo -n "Should MariaDB/MySQL be on this system? [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo apt install mariadb-server -y
  sudo apt install mysql-server -y
  sudo apt install mysql-common -y
  sudo mysql_secure_installation
  echo "CREATE USER 'hostname'@'localhost' IDENTIFIED BY '<password>'; GRANT ALL PRIVILEGES ON *.* TO 'hostname'@'localhost'; FLUSH PRIVILEGES; exit  --- run these in mysql cli"
  sudo mysql -u root -p
  
  chattr -R -i /etc/mysql/*
  mv ~/pre-configured-files/my.cnf /etc/mysql/my.cnf
  chmod 640 /etc/mysql/my.cnf
  chown root:root /etc/mysql/my.cnf
  systemctl start mariadb
  sudo service mariadb restart
  echo "mysql/mariadb configured" >> ~/script.log
  chown mysql:mysql /usr/local/mysql/data
else
  sudo apt autoremove --purge mariadb-server -y
  sudo apt autoremove --purge mysql-server -y
  clear
  echo "may wanna remove sql...if so, pls do so manually" >> ~/script.log
fi
clear
#apache2 configs
echo -n "Should Apache2 be on this system? [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  apt-get install -y -qq apache2
  ufw allow http 
  ufw allow https
  sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
  sudo cp /etc/apache2/conf-enabled/security.conf /etc/apache2/conf-enabled/security.conf.bak
  cp /etc/apache2/apache2.conf ~/Desktop/backups
  rm /etc/apache2/apache2.conf
  cp ~/pre-configured-files/apache2.conf ~/etc/apache2/apache2.conf
  if [ -e /etc/apache2/apache2.conf ]
	then
  	  echo "<Directory />" >> /etc/apache2/apache2.conf
	  echo "        AllowOverride None" >> /etc/apache2/apache2.conf
	  echo "        Order Deny,Allow" >> /etc/apache2/apache2.conf
	  echo "        Deny from all" >> /etc/apache2/apache2.conf
	  echo "</Directory>" >> /etc/apache2/apache2.conf
	  echo "UserDir disabled root" >> /etc/apache2/apache2.conf
  fi

  sudo apt-get install libapache2-modsecurity
  sudo apt-get install libapache2-mod-evasive
  sudo a2enmod headers
  sudo service apache2 restart
  echo -e "make sure you have these things:\nOptions -Indexes -FollowSymLinks"
  echo 'Make sure to have this:
    /etc/apache2/apache2.conf
        KeepAlive On
        KeepAliveTimeout 5
        HostnameLookups On
        LogLevel error
        FileETag None
        TraceEnable off
        MaxRequestPerChild 10000
        <IfModule mod_headers.c>
            Header always append X-FRAME-OPTIONS DENY
        </IfModule>
        <Directory /path/to/htdocs>
            Options -Indexes -Includes -ExecCGI
            Order allow,deny
            Allow from all
        </Directory>
    /etc/apache2/conf-enabled/security.conf
        ServerTokens Prod
        ServerSignature Off
        Header set X-Content-Type-Options: "nosniff"
    /etc/apache2/modsecurity/modsecurity.conf
        SecRuleEngine On
    /etc/apache2/mods-enabled/security2.conf
        IncludeOptional "/usr/share/modsecurity-crs/*.conf"
        IncludeOptional "/usr/share/modsecurity-crs/base_rules/*.conf
  ' > ~/apacheinstructions.txt
  #sudo nano /etc/apache2/apache2.conf
  #sudo nano /etc/apache2/conf-enabled/security.conf
  sudo mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf.
  #sudo nano /etc/apache2/modsecurity/modsecurity.conf
  #sleep 10
  #sudo nano /etc/apache2/mods-enabled/security2.conf
  cd ~
  sudo apt-get install git
  sudo git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
  sudo cd owasp-modsecurity-crs
  sudo mv crs-setup.conf.example /etc/modsecurity/crs-setup.conf
  if [ -d "/etc/modsecurity/rules" ]
  then
  # Control will enter here if $DIRECTORY exists.
    sudo mv rules/ /etc/modsecurity
  else
      sudo mkdir /etc/modsecurity/rules
      cd rules 
      sudo cp *.* /etc/modsecurity/rules
  fi
  echo 'Remember to add the following:
      IncludeOptional /etc/modsecurity/*.conf
      Include /etc/modsecurity/rules/*.conf
  ' >> ~/apacheinstructions.txt
  #sudo nano /etc/apache2/mods-enabled/security2.conf

  sudo chown -R 750 /etc/apache2/bin /etc/apache2/conf
  sudo chmod 511 /usr/sbin/apache2
  sudo chmod 750 /var/log/apache2/
  sudo chmod 750 /etc/apache2/conf/
  sudo chmod 640 /etc/apache2/conf/*
  # sudo chgrp -R <MyApacheUser> /etc/apache2/conf

  sudo a2dismod userdir
  sudo a2dismod suexec
  sudo a2dismod cgi
  sudo a2dismod cgid
  sudo a2dismod include


  sudo service apache2 restart
  chown -R root:root /etc/apache2
  echo "http and https ports allowed on the firewall. Apache2 config file configured. Only root can now access the Apache2 folder." >> ~/script.log
  chown -R root:root /etc/apache2
  chown -R root:root /etc/apache
  echo "
  <Directory />
  	AllowOverride None
	Order deny,allow
	LimitRequestBody 102400
	Options -Indexes -Includes -FollowSymLinks -ExecCGI
  </Directory>" >> /etc/apache2/apache2.conf
  sudo service apache2 restart
  echo "apache2 configured"
else
  sudo apt-get autoremove --purge apache2 apache2* -y
  apt-get -y -qq purge apache2
	rm -r /var/www/*
  echo "apache2 deleted" >> script.log
fi
clear

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

##Change version to latest!
echo -n "Do you want to configure PHP7.0? [Y/n]"
read option
if [[ $option =~ ^[Yy]$ ]]
then
	#echo "make sure that under the disable_functions section in the /etc/php/7.x/php.ini, shell_exec is added to the list" > ~/DOTHISFORPHP.txt
	# Install the necessary packages for PHP7 and security hardening
	#sudo apt-get install php7.0 php7.0-cli php7.0-common libapache2-mod-php7.0 -y
	sudo apt-get install libapache2-modsecurity -y
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
echo "lamp script completed!" >> ~/script.log
