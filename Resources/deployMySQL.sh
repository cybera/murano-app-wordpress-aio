#!/bin/bash

vol='/dev/'$(sudo lsblk -o name,type,mountpoint,label,uuid | grep -v root | grep -v ephem | grep -v SWAP | grep -v vda | tail -1 |awk '{print $1}')
mkfs -t ext4 $vol
mkdir /opt/mysql_data
mount $vol /opt/mysql_data
echo "$vol /opt/mysql_data ext4 defaults 0 1 "| sudo tee --append  /etc/fstab

if (python -mplatform | grep -qi Ubuntu)
then #Ubuntu
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password %ROOT_MYSQL_PASSWORD%'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password %ROOT_MYSQL_PASSWORD%'
  apt-get -y update
  apt-get -y -q install mysql-server-5.6
  service mysql stop
  mv /var/lib/mysql /opt/mysql_data/
  ln -s /opt/mysql_data/mysql /var/lib/mysql
  echo "/opt/mysql_data/mysql/ r,
/opt/mysql_data/mysql/** rwk," | sudo tee --append /etc/apparmor.d/local/usr.sbin.mysqld
  service apparmor restart
  service mysql restart

else #CentOS
  yum clean all
  yum install -y centos-release-openstack-mitaka
  yum -y  update
  yum -y install mariadb-server mariadb
  systemctl enable mariadb
  mv /var/lib/mysql /opt/mysql_data/
  sed -i -e "s|var/lib|opt/mysql_data|g" /etc/my.cnf.d/mariadb-server.cnf
  sed -i -e "s|\[client\]|\[client\]\nsocket=/opt/mysql_data/mysql/mysql.sock|g" /etc/my.cnf.d/client.cnf
  setenforce 0
  sed -i -e "s|enforcing|disabled|g" /etc/selinux/config
  systemctl start mariadb
  mysqladmin -u root password %ROOT_MYSQL_PASSWORD%
fi

mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "CREATE DATABASE wordpress"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '%WP_MYSQL_PASSWORD%'"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost' WITH GRANT OPTION"
mysql --user=root --password='%ROOT_MYSQL_PASSWORD%' -e "FLUSH PRIVILEGES"
