FROM  ubuntu-14.04-base-img
MAINTAINER Yuriy Furko <furkoyuriy@gmail.com>

RUN  apt-get update && apt-get install -y ca-certificates wget &&  rm -rf /var/lib/apt/lists/*

RUN cd /tmp/ && \
    wget http://nginx.org/keys/nginx_signing.key && \
    sudo apt-key add nginx_signing.key

RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y nginx  apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www"]

RUN rm -rf /etc/nginx/conf.d/*.*
RUN rm -rf /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/sites-enabled
RUN mkdir -p /var/www
RUN chown -R root:www-data /var/www
RUN chmod -R 777 /var/www

RUN rm -f /etc/nginx/conf.d/default.conf
COPY sites-enabled/vhost.conf /etc/nginx/sites-enabled/vhost.conf
COPY phpinfo.php /var/www/phpinfo.php
RUN echo "<?php phpinfo(); ?>" > /var/www/infophp.php
RUN chmod 777 /var/www/phpinfo.php


VOLUME ["/var/cache/nginx"]
VOLUME ["/usr/share/nginx"]

# Define working directory.
WORKDIR /var/www

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
