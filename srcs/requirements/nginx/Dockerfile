FROM debian:bookworm

RUN apt update -y \
    && apt install nginx openssl -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/ssl /var/run/nginx \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out /etc/nginx/ssl/inception.crt \
        -keyout /etc/nginx/ssl/inception.key \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=abignals.42.fr/UID=abignals"

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD [ "nginx", "-g", "daemon off;" ]


