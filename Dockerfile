FROM centos:7
MAINTAINER Matthew Duggan (matthew.duggan@ciptex.com)

ENV container docker

RUN \
  yum update -y && \
  yum install -y iproute hostname inotify-tools yum-utils which wget yum-utils net-tools unzip && \
  yum clean all

RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -P /tmp && \
yum install -y /tmp/epel-release-latest-7.noarch.rpm

# Install nginx
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
yum -y install nginx

# Install Remi
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
yum-config-manager --enable remi-php56

# Install php-fpm etc as well as wget/unzip
#RUN amazon-linux-extras install php7.2-fpm
RUN yum -y install php56-php-fpm php56-php-mysql php56-php-ldap php56-php-cli php56-php-mbstring php56-php-pdo php56-php-pear php56-php-xml php56-php-soap php56-php-gd

RUN mkdir -p -m 0777 /var/lib/php/session && chown -R nginx:nginx /var/lib/php/session && chmod 777 /var/lib/php/session

# Get & extract ionCube Loader
RUN wget -O /tmp/ioncube.tgz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_10.1.0.tar.gz && tar -zxf /tmp/ioncube.tgz -C /tmp

# tweak php-fpm config
RUN \
ln -s /etc/opt/remi/php56/php.ini /etc/php.ini && \
ln -s /etc/opt/remi/php56/php-fpm.conf /etc/php-fpm.conf && \
ln -s /etc/opt/remi/php56/php-fpm.d /etc/php-fpm.d && \
ln -s /opt/remi/php56/root/usr/sbin/php-fpm /usr/sbin/php-fpm

RUN \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s|listen = 127.0.0.1:9000|listen = /var/run/php-fpm.sock|g" /etc/php-fpm.d/www.conf && \
sed -i -e "s|;listen.owner = nobody|listen.owner = nginx|g" /etc/php-fpm.d/www.conf && \
sed -i -e "s|;listen.group = nobody|listen.group = nginx|g" /etc/php-fpm.d/www.conf && \
sed -i -e "s|;listen.mode = 0660|listen.mode = 0750|g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/user = apache/user = nginx/g" /etc/php-fpm.d/www.conf && \
sed -i -e "s/group = apache/group = nginx/g" /etc/php-fpm.d/www.conf

ADD php.ini /etc/opt/remi/php56/php.ini
ADD whmcs-configuration.php /tmp/configuration.php

# nginx site conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
RUN rm -Rf /etc/nginx/conf.d/* && \
mkdir -p /etc/nginx/ssl/
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf

# Start Supervisord
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# copy in WHMCS archive
ADD src/whmcs_v750_full.zip /whmcs.zip

# fix permissions
RUN chown -Rf nginx.nginx /usr/share/nginx/html/

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

# Expose Ports
#EXPOSE 443
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]