FROM debian:trixie

RUN apt update -y \
    && apt install nginx -y \
    && apt install vim -y \
    && apt install curl -y \
    && mkdir -p etc/nginx/ssl \
    && apt install openssl -y \
    && openssl req -x509 -nodes -out etc/nginx/ssl/inception.crt -keyout etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=abignals.42.fr/UID=abignals"
