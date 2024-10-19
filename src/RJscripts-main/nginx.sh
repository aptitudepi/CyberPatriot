cd /etc/nginx
tar -czvf nginx_$(date +'%F_%H-%M-%S').tar.gz *
apt install --reinstall nginx -y
apt autoremove --purge apache2 -y
cp /etc/nginx ~/nginxbackup
#tar -xzvf ~/pre-configured-files/nginx/nginxconfig.io-example.com.tar.gz | xargs chmod 0644
cd /etc
cp -r nginx nginxback
mv ~/pre-configured-files/nginx/nginxconfig.io-example.com.tar.gz /etc 
tar -xzvf ~/pre-configured-files/nginx/nginxconfig.io-example.com.tar.gz | xargs chmod 0644
mv nginxconfig.io-example.com.tar.gz nginx
cd /etc/nginx
mkdir -p /var/www/_letsencrypt
echo "double check configs and fix whatever is needed (server name and what not)"
