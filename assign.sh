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
i=$(whoami)
sudo chown $i: /etc/php/7.1/fpm/php.ini
sudo echo "cgi.fix_path=0" >> /etc/php/7.1/fpm/php.ini
sudo systemctl restart php*


#get domain name
read -p "Enter domain name:" domaine
sudo echo "127.0.0.1	$domain" >> /etc/hosts
