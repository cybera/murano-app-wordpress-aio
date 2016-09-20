#!/bin/bash

sudo apt-get install -y -q unzip
sudo apt-get install -y -q php5-mysql
sudo apt-get install -y -q install mysql-client

wget http://wordpress.org/latest.zip
sudo unzip -q latest.zip -d /var/www/html/
sudo mv /var/www/html/wordpress/* /var/www/html
sudo rmdir /var/www/html/wordpress
sudo chown -R www-data.www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo mkdir -p /var/www/html/wp-content/uploads
sudo chown -R :www-data /var/www/html/wp-content/uploads
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php

sudo sed -e "s/define('DB_NAME'.*$/define('DB_NAME', 'wordpress');/" -i /var/www/html/wp-config.php
sudo sed -e "s/define('DB_USER'.*$/define('DB_USER', 'wp_user');/" -i /var/www/html/wp-config.php
sudo sed -e "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', '%WP_MYSQL_PASSWORD%');/" -i /var/www/html/wp-config.php
sudo sed -e "s/define('DB_HOST'.*$/define('DB_HOST', 'localhost');/" -i /var/www/html/wp-config.php

rm /var/www/html/index.html

sudo service apache2 restart
