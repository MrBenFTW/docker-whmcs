#!/bin/bash

# Display PHP error's or not
if [[ "$ERRORS" == "true" ]] ; then
  sed -i -e "s/error_reporting =.*/error_reporting = E_ALL/g" /etc/php.ini
  sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php.ini
fi

# Set PHP timezone
if [ -z "$PHPTZ" ]; then
  PHPTZ="Australia/Sydney"
fi
#echo date.timezone = $PHPTZ >>/etc/php.ini

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

cp /tmp/ioncube/ioncube_loader_lin_5.6.so /opt/remi/php56/root/usr/lib64/php/modules
chmod 755 /opt/remi/php56/root/usr/lib64/php/modules/ioncube_loader_lin_5.6.so

# Install WHMCS
if [ ! -e /usr/share/nginx/html/.first-run-complete ]; then
  
  #extract whmcs into place
  rm -f /usr/share/nginx/html/*.html
  #unzip -q /whmcs.zip -d  /usr/share/nginx/html && mv /usr/share/nginx/html/whmcs /usr/share/nginx/html/
  unzip /whmcs.zip -d /usr/share/nginx/html && mv /usr/share/nginx/html/whmcs/* /usr/share/nginx/html && rmdir /usr/share/nginx/html/whmcs
  touch /usr/share/nginx/html/configuration.php && chown nginx:nginx /usr/share/nginx/html/configuration.php && chmod 0777 /usr/share/nginx/html/configuration.php
  rm -f /whmcs.zip

  #extract xero-addon into place
  unzip -q /xero.zip -d  /usr/share/nginx/html/
  rm -f /xero.zip

  echo "Do not remove this file." > /usr/share/nginx/html/.first-run-complete
fi

if [ -s /usr/share/nginx/html/configuration.php ]
then
  echo "File has something, deleting install dir";
  rm -rf /usr/share/nginx/html/install/
else
  echo "File is empty, not deleting install dir";
fi

# Again set the right permissions (needed when mounting from a volume)
chown -Rf nginx:nginx /usr/share/nginx/html/

# Start the first process
/usr/sbin/php-fpm -c /etc/php-fpm.conf && /usr/sbin/nginx
