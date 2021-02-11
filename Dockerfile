FROM debian:buster
WORKDIR /tmp/

# Install some basic packages vim/man for convenience

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install wget

RUN apt-get -y install vim
RUN apt-get -y install man
RUN apt-get -y install net-tools


# Variables

ENV WPDB_NAME='wp_database'
ENV WPDB_USERNAME='wp_admin'
ENV WPDB_PASSWORD='wpdb123'
ENV WP_ADMIN='mraasvel'
ENV WP_EMAIL='mraasvel@student.codam.nl'
ENV WP_PASSWORD='wp123'


# Get all scripts/files and set permissions

# COPY ./srcs/* /tmp/
# RUN chmod 777 /tmp/*.sh


# Install nginx

RUN apt-get -y install nginx

# Install MariaDB

RUN apt-get -y install mariadb-server

# Install PHP and move into phpadmin folder

RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english /var/www/html/phpmyadmin
RUN chmod -R 755 /var/www/html/phpmyadmin
RUN chown -R www-data:www-data /var/www/html/phpmyadmin

# Install wordpress

RUN wget http://wordpress.org/latest.tar.gz
RUN tar -xzf latest.tar.gz


# Set up configuration for nginx

COPY ./srcs/nginx_conf /tmp/

RUN mv /tmp/nginx_conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/nginx_conf /etc/nginx/sites-enabled/
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/OU=Codam/CN=fortytwo"

# Configure PHP

COPY ./srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php

# Configure database

COPY ./srcs/init_db.sh /tmp
RUN chmod 777 /tmp/init_db.sh
RUN bash /tmp/init_db.sh

# Configure Wordpress

COPY ./srcs/init_wp.sh /tmp/
RUN chmod 777 /tmp/init_wp.sh
# Change url to https://localhost/wordpress after adding SSL
RUN bash /tmp/init_wp.sh




# Set user to www-data and set permissions

COPY ./srcs/index.html /var/www/html
RUN rm /var/www/html/index.nginx-debian.html
RUN chmod 755 /var/www/html/index.html
RUN chown www-data:www-data /var/www/html/index.html
# RUN chmod -R 755 /var/www/html
# RUN chown -R www-data:www-data /var/www/html


# Start bash

COPY srcs/start.sh /tmp/
RUN chmod 777 /tmp/start.sh
WORKDIR /var/www/html/
CMD bash /tmp/start.sh && bash
