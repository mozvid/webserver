#!/bin/bash
clear
# Checking permissions
if [[ $EUID -ne 0 ]]; then
   ee_lib_echo_fail "Sudo privilege required..."
   exit 100
fi

# Define echo function
# Blue color
function ee_lib_echo()
{
   echo $(tput setaf 4)$@$(tput sgr0)
}
# White color
function ee_lib_echo_info()
{
   echo $(tput setaf 7)$@$(tput sgr0)
}
# Red color
function ee_lib_echo_fail()
{
   echo $(tput setaf 1)$@$(tput sgr0)
}

# Execute: update
ee_lib_echo "Bismillahirrahmanirrahim..."
clear
ee_lib_echo "Updating, please wait..."
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf update
dnf install wget tar
clear

# Execute: installing
ee_lib_echo "Installing Web Server, please wait..."
dnf install nginx
systemctl enable nginx
systemctl start nginx

rm -f /etc/nginx/nginx.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/widaryanto/webserver/master/nginx.conf

ee_lib_echo "Installing Firewall, please wait..."
dnf install firewalld
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
systemctl reload firewalld

ee_lib_echo "Installing php 7.4, please wait..."
dnf module install php:remi-7.4
dnf install php-fpm php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json
systemctl enable php-fpm
systemctl start php-fpm

yum clean all
chown nginx:nginx /var/www/html -R
systemctl restart nginx php-fpm
clear

ee_lib_echo "Installing Finished"
php -v
httpd -v
