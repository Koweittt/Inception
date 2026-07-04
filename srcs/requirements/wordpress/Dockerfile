FROM debian:bookworm

RUN apt-get update -y && apt-get install -y \
    wget php php-fpm php-mysql mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www \
    && cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz \
    && rm wordpress-6.0-fr_FR.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf \
    && mkdir -p /run/php

COPY conf/auto_config.sh /var/www/wordpress/auto_config.sh
RUN chmod +x /var/www/wordpress/auto_config.sh

ENTRYPOINT ["/var/www/wordpress/auto_config.sh"]