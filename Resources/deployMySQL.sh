#!/bin/bash

vol='/dev/'$(sudo lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v vda | tail -1 |awk '{print $1}')

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password %ROOT_MYSQL_PASSWORD%'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password %ROOT_MYSQL_PASSWORD%'

sudo mkfs -t ext4 $vol
sudo mkdir /opt/mysql_data
sudo mount $vol /opt/mysql_data

sudo apt-get -y update
sudo apt-get -y -q install mysql-server-5.6
sudo service mysql stop

sudo cp -a /var/lib/mysql/ /opt/mysql_data/
sudo rm -rf /var/lib/mysql/
sudo ln -s /opt/mysql_data/mysql /var/lib/mysql

echo "$vol /opt/mysql_data ext4 defaults 0 1 "| sudo tee --append  /etc/fstab
sudo chown -R mysql:mysql /opt/mysql_data/mysql

echo "/opt/mysql_data/mysql/ r,
/opt/mysql_data/mysql/** rwk," | sudo tee --append /etc/apparmor.d/local/usr.sbin.mysqld

sudo service mysql restart


mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "CREATE DATABASE wordpress"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '%WP_MYSQL_PASSWORD%'"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost' WITH GRANT OPTION"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "FLUSH PRIVILEGES"
