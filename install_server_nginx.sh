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

# Green color
function ee_lib_echo_text()
{
   echo $(tput setaf 127)$@$(tput sgr0)
}

# Red color
function ee_lib_echo_fail()
{
   echo $(tput setaf 1)$@$(tput sgr0)
}

# =======================================================================================

# Execute: update
ee_lib_echo_text "Updating, please wait..."
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf -y module install php:remi-7.4
dnf -y install php-fpm php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json
systemctl enable php-fpm
systemctl start php-fpm
