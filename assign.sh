#!/bin/bash
echo "Please wait while while all necessary components are being installed."
echo "" > log
sudo apt-get install nginx >> log
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server >> log
echo "Mysql installation complete"
sudo apt-get install php-fpm php-mysql >> log
echo "cgi.fix_path=0" >> /etc/php/7.0/fpm/php.ini
sudo systemctl restart php*


