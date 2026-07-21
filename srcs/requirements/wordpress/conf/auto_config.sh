#!/bin/sh
set -e

SQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

until mysqladmin ping -h mariadb --silent; do
  echo "Waiting for MariaDB..."
  sleep 2
done

cd /var/www/wordpress

if [ ! -f wp-config.php ]; then
  wp config create --allow-root \
    --dbname="$SQL_DATABASE" \
    --dbuser="$SQL_USER" \
    --dbpass="$SQL_PASSWORD" \
    --dbhost="mariadb:3306"

  wp core install --allow-root \
    --url="https://$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"

  wp user create --allow-root "$WP_USER" "$WP_USER_EMAIL" \
    --role=author --user_pass="$WP_USER_PASSWORD"
fi

exec php-fpm8.2 -F