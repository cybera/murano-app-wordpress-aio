#!/bin/bash

if (python -mplatform | grep -qi Ubuntu)
then #Ubuntu
  sudo apt-get update
  sudo apt-get install -y apache2 libapache2-mod-php
else #CentOS
  yum clean all
  yum -y  update
  yum -y install httpd mod_ssl
  /sbin/chkconfig httpd on
  service httpd restart
fi
