FROM debian:buster
WORKDIR /tmp/

# Install some basic packages vim/man for convenience : REMOVE BEFORE TURNING IN

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get -y install wget

# NginX
#
# 1. Install
# 2. Copy new config and link to it so nginx uses it
# 3. Generate SSL key and certificate pair for SSL

RUN apt-get -y install nginx
COPY ./srcs/nginx_conf /tmp/
RUN mv /tmp/nginx_conf /etc/nginx/sites-available && \
	ln -s /etc/nginx/sites-available/nginx_conf /etc/nginx/sites-enabled/ && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ft_server.key -out /etc/ssl/certs/ft_server.crt \
	-subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/CN=localhost"

# MariaDB install
RUN apt-get -y install mariadb-server

# PHP
#
# 1. Install
# 2. Copy new config
# 3. Set permissions

RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring && \
	wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz && \
	tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz && \
	mv phpMyAdmin-5.0.1-english /var/www/html/phpmyadmin
COPY ./srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php
RUN chmod -R 755 /var/www/html/phpmyadmin && \
	chown -R www-data:www-data /var/www/html/phpmyadmin

# Install wordpress
RUN wget http://wordpress.org/latest.tar.gz && \
	tar -xzf latest.tar.gz

# Configure database
ENV WPDB_NAME='wp_database'
ENV WPDB_USERNAME='db_admin'
ENV WPDB_PASSWORD='db123'

COPY ./srcs/init_db.sh /tmp
RUN chmod 777 /tmp/init_db.sh && \
	bash /tmp/init_db.sh

# Configure Wordpress
ENV WP_ADMIN='wp_admin'
ENV WP_EMAIL='mraasvel@student.codam.nl'
ENV WP_PASSWORD='wp123'

COPY ./srcs/init_wp.sh /tmp/
RUN chmod 777 /tmp/init_wp.sh && \
	bash /tmp/init_wp.sh


# Set user to www-data and set permissions
COPY ./srcs/index.html /var/www/html
RUN rm /var/www/html/index.nginx-debian.html && \
	chmod 755 /var/www/html/index.html && \
	chown www-data:www-data /var/www/html/index.html

# Set default autoindex option
WORKDIR /
ENV AUTOINDEX='off'
COPY ./srcs/autoindex.sh .
RUN chmod 755 autoindex.sh && \
	bash autoindex.sh ${AUTOINDEX}

# Create some directory to show autoindexing functionality
RUN mkdir /var/www/html/autoindex && \
	touch /var/www/html/autoindex/file_1 && \
	touch /var/www/html/autoindex/file_2 && \
	touch /var/www/html/autoindex/file_3 && \
	chown -R www-data:www-data /var/www/html/autoindex

# Finally start all services
CMD service nginx start && \
	service php7.3-fpm start && \
	service mysql start && \
	/bin/bash
