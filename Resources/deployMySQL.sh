#!/bin/bash

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password %ROOT_MYSQL_PASSWORD%'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password %ROOT_MYSQL_PASSWORD%'

sudo apt-get -y -q install mysql-server
service mysql restart

mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "CREATE DATABASE wordpress"
mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '%WP_MYSQL_PASSWORD%'"
mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost' WITH GRANT OPTION"
mysql --user=root --password=%ROOT_MYSQL_PASSWORD% -e "FLUSH PRIVILEGES"
