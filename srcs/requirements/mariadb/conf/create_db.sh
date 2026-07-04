#!/bin/sh
set -e

SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    service mariadb start

    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    mysqladmin -uroot -p"${SQL_ROOT_PASSWORD}" shutdown
fi

exec mysqld_safe