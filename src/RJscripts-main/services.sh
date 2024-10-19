#!/bin/bash
echo "Please double-check where all FTP config files are located (e.g., /etc/vsftpd.conf or /etc/vsftpd/vsftpd.conf) BEFORE RUNNING"
echo -n "VSFTPd [Y/n] "
read vsftpd
if [[ $vsftpd =~ ^[Yy]$ ]]; then
  cp ~/pre-configured-files/vsftpd.conf /etc/vsftpd.conf
  sudo apt-get -y install vsftpd
  sudo systemctl is-enabled vsftpd
  # Disable anon uploads
  sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
  sudo sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
  # User directories use chroot in FTP
  sudo sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
  # Encryption and keys
  echo "write_enable=YES" >> /etc/vsftpd.conf
  echo "local_root=/ftp" >> /etc/vsftpd.conf
  echo "userlist_file=/etc/vsftpd/user_list" >> /etc/vsftpd.conf
  echo "userlist_deny=NO" >> /etc/vsftpd.conf
  echo "vsftpd_log_file=/var/log/vsftpd.log" >> /etc/vsftpd.conf
  echo "ssl_enable=YES" >> /etc/vsftpd.conf
  echo "allow_anon_ssl=NO" >> /etc/vsftpd.conf
  echo "force_local_data_ssl=YES" >> /etc/vsftpd.conf
  echo "force_local_logins_ssl=YES" >> /etc/vsftpd.conf
  echo "userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH" >> /etc/vsftpd.conf
  sudo ufw allow 50000:50100/tcp
  sudo service vsftpd restart
  echo "VSFTPd successfully configured.... Please add this to the end of the config file (with newlines) user_sub_token=dollarsign(the symbol)USER   local_root=/home/dollarsignUSER/chroot   Also, use this https://www.howtoforge.com/tutorial/ubuntu-vsftpd/ if you need more configs" >> script.log
else
  sudo apt-get -y autoremove --purge vsftpd*
  echo "VSFTPd successfully deleted" >> script.log
fi

# Proftpd
echo -n "Proftpd [Y/n] "
read proftpd
if [[ $proftpd =~ ^[Yy]$ ]]; then
  apt install proftpd -y
  echo "Update proftpd configurations? Answering no will delete proftpd."
  read yn
  if [ "$yn" = "y" ]; then
    echo "changing proftpd configurations"
    cp ~/pre-configured-files/proftpd /etc/proftpd.conf
    echo "restarting the service"
    systemctl restart proftpd
  else
    apt autoremove -y --purge proftpd
    echo "proftpd deleted."
  fi
fi

# Pure-FTPd
echo -n "pure-ftpd [Y/n] "
read pureftpd
if [[ $pureftpd =~ ^[Yy]$ ]]; then
  apt install pure-ftpd pure-ftpd-wrapper -y
  echo "changing pure-ftpd configurations"
  cp ~/pre-configured-files/pure-ftpd /etc/pure-ftpd/pure-ftpd.conf
  cd /etc/pure-ftpd/conf
  echo yes > ChrootEveryone
  echo yes > DontResolve
  echo yes > NoChmod
  echo yes > ProhibitDotFilesWrite
  echo yes > CustomerProof
  echo '20000 20099' > PassivePortRange
  echo 2 > TLS
  mkdir /etc/ssl/private
  openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
  chmod 600 /etc/ssl/private/pure-ftpd.pem

  echo "Should this FTP server be anonymous? (usually not) y/n"
  read yn
  if [ $yn = "n" ]; then
    echo yes > NoAnonymous
    echo no > AnonymousOnly
  fi
  if [ $yn = "y" ]; then
    echo no > NoAnonymous
    echo yes > AnonymousOnly
  fi
  echo no > UnixAuthentication
  echo yes > PamAuthentication
  echo "restarting the service"
  systemctl restart pure-ftpd
  cd

  cd /etc/pure-ftpd/conf
  echo no > BrokenClientsCompatibility
  echo 50 > MaxClientsNumber
  echo 2 > MaxClientsPerIP
  echo yes > VerboseLog
  echo no > DisplayDotFiles
  echo yes > ProhibitDotFilesWrite

  echo yes > NoChmod
  echo no > DontResolve
  echo 15 > MaxIdleTime
  echo yes > LimitRecursion
  echo yes > AntiWarez
  echo no > AnonymousCanCreateDirs
  echo 1 > MaxLoad
  echo no > AllowUserFXP
  echo no > AllowAnonymousFXP
  echo yes > AnonymousCantUpload
else
  if dpkg -l | grep pure-ftpd; then
    apt autoremove -y --purge pure-ftpd
    echo "pure-ftpd deleted."
  fi
fi
