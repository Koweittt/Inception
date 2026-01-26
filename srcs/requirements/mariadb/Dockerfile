FROM debian:bookworm

RUN apt update -y \
    && apt-get install mariadb-server -y \
    && mkdir launch_sh

COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf
COPY conf/create_db.sh launch_sh/create_db.sh

RUN chmod 777 launch_sh/create_db.sh

ENTRYPOINT ["launch_sh/create_db.sh"]