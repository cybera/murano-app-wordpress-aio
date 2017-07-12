#!/bin/bash

if (python -mplatform | grep -qi Ubuntu)
then #Ubuntu
  apt-get install -y -q unzip php5-mysql mysql-client

  wget http://wordpress.org/latest.zip
  unzip -q latest.zip -d /var/www/html/
  mv /var/www/html/wordpress/* /var/www/html
  rmdir /var/www/html/wordpress
  chown -R www-data.www-data /var/www/html
  chmod -R 755 /var/www/html
  mkdir -p /var/www/html/wp-content/uploads
  chown -R :www-data /var/www/html/wp-content/uploads
  cd /var/www/html
  cp wp-config-sample.php wp-config.php

  sed -e "s/define('DB_NAME'.*$/define('DB_NAME', 'wordpress');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_USER'.*$/define('DB_USER', 'wp_user');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', '%WP_MYSQL_PASSWORD%');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_HOST'.*$/define('DB_HOST', 'localhost');/" -i /var/www/html/wp-config.php
  chown -R www-data.www-data /var/www/html
  rm /var/www/html/index.html

  echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ServerName %WP_FLOATING_IP%
    <Directory /var/www/html/>
        AllowOverride All
    </Directory>
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/000-default.conf
  a2enmod rewrite
  touch /var/www/html/.htaccess
  chown :www-data /var/www/html/.htaccess
  chmod 664 /var/www/html/.htaccess
  size1=%WP_UPLOAD_SIZE%"M"
  size2=%WP_UPLOAD_SIZE%
  ((size2+=10))
  size2+="M"
  echo "php_value upload_max_filesize $size1
php_value post_max_size $size2" >/var/www/html/.htaccess
  service apache2 restart

else #CentOS
  yum install -y php-gd wget php php-mysql
  service httpd restart
  cd ~
  wget http://wordpress.org/latest.tar.gz
  tar xzvf latest.tar.gz
  rsync -avP ~/wordpress/ /var/www/html/
  mkdir /var/www/html/wp-content/uploads
  chown -R apache:apache /var/www/html/*
  cd /var/www/html
  cp wp-config-sample.php wp-config.php
  sed -e "s/define('DB_NAME'.*$/define('DB_NAME', 'wordpress');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_USER'.*$/define('DB_USER', 'wp_user');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', '%WP_MYSQL_PASSWORD%');/" -i /var/www/html/wp-config.php
  sed -e "s/define('DB_HOST'.*$/define('DB_HOST', 'localhost');/" -i /var/www/html/wp-config.php
  chown -R apache:apache /var/www/html/*
  sed -e "s/DirectoryIndex.*$/DirectoryIndex index.html index.php/" -i /etc/httpd/conf/httpd.conf
  sed -e "s/AllowOverride.*$/AllowOverride All/" -i /etc/httpd/conf/httpd.conf
  touch /var/www/html/.htaccess
  chown apache /var/www/html/.htaccess
  chmod 664 /var/www/html/.htaccess
  systemctl restart  httpd
fi
