#!/bin/bash

echo "Update the package manager cache before running"
sleep 5
# Install PHP 7.0 and the required dependencies
#apt-get install -y php7.0 libapache2-mod-php7.0

# Enable the mod_headers and mod_ssl Apache modules
a2enmod headers ssl

# Create a PHP configuration file
#echo "
## Set the display_errors flag to "Off" to prevent sensitive information from being leaked to the client
#display_errors = Off

# Set the log_errors flag to "On" to log errors to the server error log
#log_errors = On

# Set the error_log to a secure location
#error_log = /var/log/php/error.log

# Set the session.cookie_secure flag to "1" to only allow the session cookie to be transmitted over secure connections
#session.cookie_secure = 1

# Set the session.use_only_cookies flag to "1" to only use cookies for storing session IDs
#session.use_only_cookies = 1
#" > /etc/php/7.0/apache2/php.ini

# Create the PHP log directory and set the correct permissions
mkdir -p /var/log/php
chown -R root:adm /var/log/php
chmod -R 750 /var/log/php

# Restart Apache to apply the changes
systemctl restart apache2
