#!/bin/bash
# ======================= install php 7.4 =======================
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf -y update
dnf -y module install php:remi-7.4
dnf -y install php-fpm php-cli php-mysqlnd php-pecl-memcached -y php-common php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json tar wget htop screen nano

systemctl enable php-fpm
systemctl start php-fpm
php -v

# ======================= install nginx =======================
dnf -y install nginx

systemctl enable nginx
systemctl start nginx
nginx -v

# ======================= install memcached =======================
dnf -y install memcached libmemcached -y

systemctl enable memcached
systemctl start memcached
#systemctl status memcached

# ======================= install mysql =======================
dnf -y install mysql-server

systemctl start mysqld.service
systemctl enable mysqld

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('cr0nichetzner') WHERE User='root';
#DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

#mysql_secure_installation
#n
#isi password
#y
#y
#y
#y

# ======================= install iptables =======================
dnf -y install iptables iptables-services

systemctl enable iptables
systemctl start iptables
#systemctl status iptables
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save
systemctl restart iptables

# ======================= setting firewall =======================
dnf -y install firewalld
systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-port=3306/tcp
systemctl reload firewalld

# ======================= finishing install =======================
chown -R nginx:nginx /var/www/html
chown -R nginx:nginx /var/lib/php
chmod -R 777 /var/www/html
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_unified 1

rm -f /etc/nginx/nginx.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/mozvid/webserver/master/nginx.conf
rm -f /etc/nginx/default.d/php.conf
curl -o /etc/nginx/default.d/php.conf https://raw.githubusercontent.com/mozvid/webserver/master/php.conf
rm -f /etc/php-fpm.d/www.conf
curl -o /etc/php-fpm.d/www.conf https://raw.githubusercontent.com/mozvid/webserver/master/www.conf
curl -o /var/www/html https://raw.githubusercontent.com/mozvid/webserver/master/info.php
reboot
