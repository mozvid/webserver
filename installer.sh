#!/bin/bash
printf "$(tput setaf 2)======================= install php 7.4 =======================\n$(tput sgr0)"
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf -y update
dnf -y module install php:remi-7.4
dnf -y install php-fpm php-cli php-mysqlnd php-pecl-memcached php-common php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json tar wget htop screen nano iotop

systemctl start php-fpm
systemctl enable php-fpm
php -v
sleep 3s

printf "$(tput setaf 2)======================= install nginx =======================\n$(tput sgr0)"
dnf -y install nginx

systemctl start nginx
systemctl enable nginx
nginx -v
sleep 3s

printf "$(tput setaf 2)======================= install memcached =======================\n$(tput sgr0)"
dnf -y install memcached libmemcached

systemctl start memcached
systemctl enable memcached
#systemctl status memcached
sleep 3s

printf "$(tput setaf 2)======================= install crontabs =======================\n$(tput sgr0)"
dnf -y install crontabs

systemctl start crond.service
systemctl enable crond.service
#systemctl status crond
crontab <<EOF
*/2 * * * * /root/autorestart.sh
EOF

printf "$(tput setaf 2)======================= install mysql =======================\n$(tput sgr0)"
dnf -y install mysql-server

systemctl start mysqld.service
systemctl enable mysqld

mysql -u root <<-EOF
CREATE USER 'remote'@'%' IDENTIFIED BY '#bismillah';
GRANT ALL PRIVILEGES ON *.* TO 'remote'@'%';
UPDATE mysql.user SET host='%' WHERE user='remote';
ALTER USER 'remote'@'%' IDENTIFIED WITH mysql_native_password BY '#bismillah';

ALTER USER 'root'@'localhost' IDENTIFIED BY '#bismillah';
FLUSH PRIVILEGES;
EOF
systemctl set-environment MYSQLD_OPTS="--skip-log-bin=1"
systemctl daemon-reload
systemctl restart mysqld
sleep 3s

printf "$(tput setaf 2)======================= setting firewall =======================\n$(tput sgr0)"
dnf -y install firewalld
systemctl start firewalld
systemctl enable firewalld

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --permanent --zone=public --add-port=11211/tcp  
systemctl reload firewalld
sleep 3s

printf "$(tput setaf 2)======================= finishing install =======================\n$(tput sgr0)"
chown -R nginx:nginx /var/www/html
chown -R nginx:nginx /var/lib/php
chmod -R 777 /var/www/html
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_unified 1
sleep 3s

printf "$(tput setaf 2)======================= Update nginx.conf =======================\n$(tput sgr0)"
rm -f /etc/nginx/nginx.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/mozvid/webserver/master/nginx.conf
sleep 3s

printf "$(tput setaf 2)======================= Update php.conf =======================\n$(tput sgr0)"
rm -f /etc/nginx/default.d/php.conf
curl -o /etc/nginx/default.d/php.conf https://raw.githubusercontent.com/mozvid/webserver/master/php.conf
sleep 3s

printf "$(tput setaf 2)======================= Update mysql-server.cnf =======================\n$(tput sgr0)"
rm -f /etc/my.cnf.d/mysql-server.cnf
curl -o /etc/my.cnf.d/mysql-server.cnf https://raw.githubusercontent.com/mozvid/webserver/master/mysql-server.cnf
sleep 3s

printf "$(tput setaf 2)======================= Update crontabs =======================\n$(tput sgr0)"
curl -o /root/autorestart.sh https://raw.githubusercontent.com/mozvid/webserver/master/autorestart.sh
chmod u+x /root/autorestart.sh
sleep 3s

printf "$(tput setaf 2)======================= Update fastcgi.conf =======================\n$(tput sgr0)"
rm -f /etc/nginx/fastcgi_params
curl -o /etc/nginx/fastcgi_params https://raw.githubusercontent.com/mozvid/webserver/master/fastcgi_params
sleep 3s

# printf "$(tput setaf 2)======================= Update www.conf =======================\n$(tput sgr0)"
# rm -f /etc/php-fpm.d/www.conf
# curl -o /etc/php-fpm.d/www.conf https://raw.githubusercontent.com/mozvid/webserver/master/www.conf
# sleep 3s

curl -o /var/www/html/info.php https://raw.githubusercontent.com/mozvid/webserver/master/info.php
sleep 3s
curl -o db-manager.php -OL  https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php
sleep 3s

printf "$(tput setaf 2)========================= install finished ========================= \n$(tput sgr0)"

#reboot
systemctl restart nginx php-fpm mysqld memcached crond.service
