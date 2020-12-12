#layers
#1 OS
FROM debian:buster

#2-3 VIM, NGINX, SQL-SERVER
RUN apt-get -y update
RUN apt-get -y install vim nginx mariadb-server mariadb-client
#default-mysql-server

#4-5 PHP
RUN apt-get -y install php-fpm php-mysql
RUN apt-get -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip

#6-13 WORDPRESS IN NGINX
RUN apt-get -y install wget
RUN chown -R www-data:www-data /var/www/html 
RUN chmod -R 755 /var/www/*
RUN apt-get -y install wordpress
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -zxvf latest.tar.gz
RUN rm -rf latest.tar.gz
RUN mv wordpress /var/www/html/

#14-17 PHPMYADMIN
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.3/phpMyAdmin-5.0.3-all-languages.tar.gz
RUN tar -zxvf phpMyAdmin-5.0.3-all-languages.tar.gz
RUN rm -rf phpMyAdmin-5.0.3-all-languages.tar.gz
RUN mv phpMyAdmin-5.0.3-all-languages/ /var/www/html/phpmyadmin

#18-19 SSL
RUN apt-get -y install openssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=ru/ST=Kazan/L=Kazan/O=no/OU=no/CN=localhost" -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt

#20-24 CONFIGS
COPY ./srcs/default /etc/nginx/sites-available/
RUN rm -rf /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
COPY ./srcs/config.inc.php /var/www/html/phpmyadmin/
COPY ./srcs/wp-config.php /var/www/html/wordpress/

#25-28 SH
COPY ./srcs/autoindex.sh .
COPY ./srcs/allstart.sh .
RUN chmod 777 allstart.sh
RUN chmod 777 autoindex.sh

# PORTS HTTP, HTTPS
EXPOSE 80 443

# SH SCRIPTS
CMD bash allstart.sh
