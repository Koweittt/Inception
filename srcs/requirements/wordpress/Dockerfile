FROM debian:bookworm

RUN apt-get update -y \
    && apt-get install -y wget \
    && apt-get install -y php7.3 \
    && apt-get install -y php-fpm \
    && apt-get install -y php-mysql \
    && apt-get install -y mariadb-client

RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz
RUN	chown -R root:root /var/www/wordpress
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

COPY conf/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf
COPY conf/auto_config.sh /var/www/wordpress/auto_config.sh

RUN chmod +x /var/www/wordpress/auto_config.sh

ENTRYPOINT ["/var/www/wordpress/auto_config.sh"]