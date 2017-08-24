#!/bin/bash
echo "Please wait while while all necessary components are being installed."
echo "" > log
rootp='root'
sudo apt-get update
sudo apt-get -y install nginx 
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
echo "Mysql installation complete"
sudo apt-get -y install php-fpm php-mysql
sudo apt-get install -y php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc


i=$(whoami)
ver=$(php -r "echo phpversion();")
ver=$(echo $ver | cut -c 1-3)
sudo chown $i: /etc/php/$ver/fpm/php.ini
sudo echo "cgi.fix_path=0" >> /etc/php/$ver/fpm/php.ini


sudo systemctl restart php*


#get domain name
read -p "Enter domain name:" domaine
sudo chown $i: /etc/hosts
sudo echo "127.0.0.1 $domaine" >> /etc/hosts
sudo chown root /etc/hosts


#mysql db
mysql -u root -p$rootp < sql_input
echo '###########################################1'


#create config


sudo cp ngconf /etc/nginx/sites-available/$domaine
sudo sed -i "s/domain_name/$domaine/g" /etc/nginx/sites-available/$domaine
sudo ln -s /etc/nginx/sites-available/$domaine /etc/nginx/sites-enabled/
echo '###########################################2'
	
if [[ $? -eq 0 ]]
	then
		echo "nginx config file created"
	else
		echo "Some error occured wile creating/linking nginx config file"
	fi
	
sudo systemctl reload nginx	
#sudo apt-get update
sudo systemctl restart php*
echo '###########################################3'

#get wordpress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz >> log
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo mkdir /var/www/$domaine
sudo cp -a /tmp/wordpress/. /var/www/$domaine
echo '###########################################4'


#set ownerships
sudo chown -R $i:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod g+s {} \;
sudo chmod g+w /var/www/html/wp-content
sudo chmod -R g+w /var/www/html/wp-content/themes
sudo chmod -R g+w /var/www/html/wp-content/plugins
echo '###########################################5'


#modify wpconfig
cd /var/www/html
	sed -i "s/database_name_here/wordpress/g" wp-config.php
	sed -i "s/username_here/wordpressuser/g" wp-config.php
	sed -i "s/password_here/password/g" wp-config.php
	
	
echo "proceed to $domaine on your browser"	
	
