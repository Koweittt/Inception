FROM debian:bookworm

RUN apt update -y \
    && apt install nginx -y \
    && mkdir -p etc/nginx/ssl \
    && apt install openssl -y \
    && openssl req -x509 -nodes -out etc/nginx/ssl/inception.crt -keyout etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=abignals.42.fr/UID=abignals" \
    && mkdir -p /var/run/nginx 

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod 755 /var/www/html \
    && chown -R www-data:www-data /var/www/html

CMD [ "nginx", "-g", "daemon off;" ]


