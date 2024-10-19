echo "This script hardens nginx, php, apache, mysql"
sleep 3
./nginx.sh
apt install --reinstall php -y

for i in $(find / -name php.ini | xargs); do
    mv $i $i.bak
    cp ~/pre-configured-files/php.ini $i
done

echo -n "Do you want to configure MySQL? [Y/n]"
read option

if [[ $option =~ ^[Yy]$ ]]; then
    # Install MySQL Server and Client
    sudo apt-get install mysql-server mysql-client -y
    # Secure MySQL Installation
    sudo mysql_secure_installation
    sudo service mysql stop
    sudo mysqld_safe --skip_networking=0
    sudo mysql --skip-networking=OFF
    sudo service mysql start
    # Set root password
    echo -n "Do you want to set the root password to 'SuP3rs3CurEmYsQL!'?"
    read mysqlrootpass

    if [[ $mysqlrootpass =~ ^[Yy]$ ]]; then
        sudo mysqladmin -u root password 'SuP3rs3CurEmYsQL!'
        sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'SuP3rs3CurEmYsQL!';"
    fi

    # Create a new user 
    #sudo mysql -u root -p  << EOF 
    #CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
    #GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost';
    #FLUSH PRIVILEGES;
    #EOF

    echo -n "Do you want to change password policies for MySQL?"
    read mysqlpasspol

    if [[ $mysqlpasspol =~ ^[Yy]$ ]]; then
        # Set MySQL password policies
        sudo mysql -e "SET GLOBAL storage_engine=INNODB;"
        sudo mysql -e "SET GLOBAL validate_password_policy=MEDIUM;"
        sudo mysql -e "SET GLOBAL validate_password_length=14;"
        sudo mysql -e "SET GLOBAL validate_password_mixed_case_count=1;"
        sudo mysql -e "SET GLOBAL validate_password_number_count=1;"
        sudo mysql -e "SET GLOBAL validate_password_special_char_count=1;"
        sudo mysql -e "SET GLOBAL validate_password_history=1;"
        sudo mysql -e "SET GLOBAL validate_password_lifetime=365;"
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

# end

echo -n "Do you want to configure PHP7.0? [Y/n]"
read option

if [[ $option =~ ^[Yy]$ ]]; then
    # Install and configure PHP7.0
    for ini in $(find / -name "php.ini" 2>/dev/null); do
        cat ~/pre-configured-files/php.ini > $ini
    done

    sudo sed -i 's/expose_php = On/expose_php = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/allow_url_include = On/allow_url_include = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/display_errors = On/display_errors = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/log_errors = Off/log_errors = On/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/register_globals = On/register_globals = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/magic_quotes_gpc = On/magic_quotes_gpc = Off/g' /etc/php/7.0/apache2/php.ini
    sudo sed -i 's/session.cookie_httponly = Off/session.cookie_httponly = On/g' /etc/php/7.0/apache2/php.ini
    # echo "php7.0 configured" >> ~/script.log
fi
