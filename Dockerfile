FROM debian:buster

# Install nginx

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install wget

RUN apt-get -y install nginx

# Install MariaDB

RUN apt-get -y install mariadb-server

# Install PHP

RUN apt-get -y install php-fpm php-mysql