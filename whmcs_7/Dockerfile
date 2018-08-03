FROM centos:7
MAINTAINER Matthew Duggan (matthew.duggan@ciptex.com)

ENV container docker

RUN \
  yum update -y && \
  yum install -y iproute hostname inotify-tools yum-utils which wget yum-utils net-tools unzip

RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -P /tmp && \
yum install -y /tmp/epel-release-latest-7.noarch.rpm

# Install nginx
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && \
yum -y install nginx cronie supervisor

# Install Remi
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
yum-config-manager --enable remi-php56

# Install php-fpm etc as well as wget/unzip
#RUN amazon-linux-extras install php7.2-fpm
RUN yum -y install php56-php-fpm php56-php-mysql php56-php-ldap php56-php-cli php56-php-mbstring php56-php-pdo php56-php-pear php56-php-xml php56-php-soap php56-php-gd php56-php-xmlrpc php56-php-imap && yum clean all

RUN mkdir -p -m 0777 /var/lib/php/session && chown -R nginx:nginx /var/lib/php/session && chmod 777 /var/lib/php/session

# Get & extract ionCube Loader
RUN wget -O /tmp/ioncube.tgz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_10.1.0.tar.gz && tar -zxf /tmp/ioncube.tgz -C /tmp

# tweak php-fpm config
RUN \
ln -s /etc/opt/remi/php56/php.ini /etc/php.ini && \
ln -s /etc/opt/remi/php56/php-fpm.conf /etc/php-fpm.conf && \
ln -s /etc/opt/remi/php56/php-fpm.d /etc/php-fpm.d && \
ln -s /opt/remi/php56/root/usr/sbin/php-fpm /usr/sbin/php-fpm 

ADD conf/php-fpm.conf /etc/opt/remi/php56/php-fpm.conf
ADD conf/php-fpm-www.conf /etc/opt/remi/php56/php-fpm.d/www.conf
ADD conf/php.ini /etc/opt/remi/php56/php.ini
ADD conf/cron.conf /etc/cron.d/whmcs
ADD conf/supervisord.conf /etc/supervisord.conf

# nginx site conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
RUN rm -Rf /etc/nginx/conf.d/* && mkdir -p /etc/nginx/ssl/
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf

# Start Supervisord
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

# copy in WHMCS archive
ADD src/whmcs-xero-2.15.zip /xero.zip
ADD src/whmcs_v760_full.zip /whmcs.zip

# fix permissions
RUN chown -Rf nginx.nginx /usr/share/nginx/html/

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

# Expose Ports
#EXPOSE 443
EXPOSE 8086
EXPOSE 8087

#CMD ["/bin/bash", "/start.sh"]
CMD ["/usr/bin/supervisord"]
