#!/bin/bash

# Display PHP error's or not
if [[ "$ERRORS" == "true" ]] ; then
  sed -i -e "s/error_reporting =.*/error_reporting = E_ALL/g" /etc/php.ini
  sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php.ini
fi

# Set PHP timezone
if [ -z "$PHPTZ" ]; then
  PHPTZ="Europe/London"
fi
#echo date.timezone = $PHPTZ >>/etc/php.ini

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Install the correct ionCube loader and WHMCS
if [ ! -e /.first-run-complete ]; then
  PHPVERSION=$(php-fpm --version | grep '^PHP' | sed 's/PHP \([0-9]\.[0-9]*\).*$/\1/')
  mkdir /usr/local/ioncube
  cp /tmp/ioncube/ioncube_loader_lin_5.6.so /opt/remi/php56/root/usr/lib64/php/modules

  #extract whmcs into place
  rm -f /usr/share/nginx/html/*.html
  unzip /whmcs.zip -d /usr/share/nginx/html && mv /usr/share/nginx/html/whmcs/* /usr/share/nginx/html && rmdir /usr/share/nginx/html/whmcs
  rm -f /whmcs.zip

  #extract xero-addon into place
  unzip /xero.zip -d /usr/share/nginx/html
  rm -f /xero.zip

  unzip /ciptex.zip -d /usr/share/nginx/html
  rm -f /ciptex.zip

  #Remove install
  rm -rf /usr/share/nginx/html/install directory

  #sort permissions on configuration.php file
  chown nginx:nginx /usr/share/nginx/html/configuration.php && chmod 0777 /usr/share/nginx/html/configuration.php

  echo "Do not remove this file." > /.first-run-complete
fi

# Again set the right permissions (needed when mounting from a volume)
chown -Rf nginx:nginx /usr/share/nginx/html/

# Start the first process
/usr/sbin/php-fpm -c /etc/php-fpm.conf && /usr/sbin/nginx


#status=$?
#if [ $status -ne 0 ]; then
#  echo "Failed to start php-fpm: $status"
#  exit $status
#fi

# Start the second process
#/usr/sbin/nginx
#status=$?
#if [ $status -ne 0 ]; then
#  echo "Failed to start nginx: $status"
#  exit $status
#fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

#while sleep 60; do
#  ps aux |grep php-fpm |grep -q -v grep
#  PROCESS_1_STATUS=$?
#  ps aux |grep nginx |grep -q -v grep
#  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
#  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
#    echo "One of the processes has already exited."
#    exit 1
#  fi
#done


