#!/bin/bash
# ======================= install php 7.4 =======================
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf update
dnf -y module install php:remi-7.4
dnf -y install php-fpm php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json tar

systemctl enable php-fpm
systemctl start php-fpm
php -v

# ======================= install nginx =======================
dnf -y install nginx

systemctl enable nginx
systemctl start nginx
nginx -v

# ======================= setting firewall =======================
dnf -y install firewalld
systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
systemctl reload firewalld

# ======================= finishing install =======================
rm -f /etc/nginx/nginx.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/widaryanto/webserver/master/nginx.conf
chown nginx:nginx /var/www/html -R
dnf clean all
systemctl restart nginx php-fpm
php -v
nginx -v
