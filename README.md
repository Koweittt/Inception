*This project has been created as part of the 42 curriculum by abignals.*

# Inception

## Description

Inception is a system administration project whose goal is to build, from
scratch, a small multi-service infrastructure running entirely inside Docker
containers on a virtual machine.

The stack serves a **WordPress** website over **HTTPS (TLSv1.2/1.3)** and is
composed of three services, each in its own dedicated container built from a
hand-written `Dockerfile` (base image: the penultimate stable Debian,
`debian:bookworm`):

- **NGINX** — the single entry point, exposed only on port **443** with TLS.
- **WordPress + php-fpm** — the website and its PHP processor.
- **MariaDB** — the database backing WordPress.

Data persists in two Docker **named volumes** stored under `~/data` on the host,
services communicate through a private **bridge network**, and all sensitive
values are provided through **Docker secrets** and a git-ignored `.env` file.

## Instructions

### Prerequisites
- A Linux host/VM with **Docker Engine**, **Docker Compose v2** and **make**.
- Map the domain locally by adding to `/etc/hosts`:
  ```
  127.0.0.1   abignals.42.fr
  ```
- Create the local secrets and environment files (not versioned) — see
  [DEV_DOC.md](DEV_DOC.md) for the exact content:
  - `secrets/db_root_password.txt`, `secrets/db_password.txt`,
    `secrets/credentials.txt`
  - `srcs/.env`

### Build & run
From the root of the repository:

```bash
make          # build the images and start the stack (docker compose up -d --build)
make status   # check the containers are up
make logs     # follow the logs
make down     # stop and remove the containers
make fclean   # full cleanup (containers, images, volumes and ~/data)
```

Then open **https://abignals.42.fr** (admin panel at `/wp-admin`). The
self-signed certificate triggers a browser warning — this is expected.

More details:
- [USER_DOC.md](USER_DOC.md) — end-user / administrator guide.
- [DEV_DOC.md](DEV_DOC.md) — developer setup, commands and data persistence.

## Resources

Documentation and references used for this project:

- [Docker documentation](https://docs.docker.com/) — Dockerfiles, images, PID 1.
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [Docker secrets in Compose](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX documentation](https://nginx.org/en/docs/) and TLS configuration.
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/documentation/)
- [WordPress](https://wordpress.org/documentation/) and
  [WP-CLI](https://developer.wordpress.org/cli/commands/) for the automated
  installation.
- [Debian releases](https://www.debian.org/releases/) to pick the penultimate
  stable base image.

### Use of AI

AI Tools were used for documentation about Docker, Compose and configuration
of the different containers.

## Project description

### Docker and the project sources

The whole infrastructure is described in `srcs/docker-compose.yml`, which builds
one image per service from the Dockerfiles in `srcs/requirements/<service>/`.
No ready-made image is pulled from DockerHub: every image is built from the
Debian base only. Entrypoint scripts (`create_db.sh`, `auto_config.sh`)
initialise MariaDB and WordPress on first boot and keep the main process as
PID 1 (no infinite-loop hacks). Configuration is injected via a `.env` file,
and confidential values (database and admin passwords) via Docker secrets.

### Main design choices — comparisons

**Virtual Machines vs Docker**
A VM virtualises a whole operating system with its own kernel, which is heavy
and slow to boot. Docker containers share the host kernel and isolate only the
processes, so they are lightweight, start in seconds and are reproducible from a
Dockerfile. Here each service is a small container instead of a full VM, which
keeps the stack fast and easy to rebuild — while the whole thing still runs
inside one VM as required by the subject.

**Secrets vs Environment Variables**
Environment variables (`.env`) are convenient for non-sensitive configuration
(domain, database name, user names) but they are exposed in the container
environment and easy to leak. Docker **secrets** are mounted as files under
`/run/secrets/`, are not part of the image nor the environment, and are meant
for confidential data. In this project passwords live in secrets, while
non-sensitive settings live in the git-ignored `.env`.

**Docker Network vs Host Network**
With `network: host`, containers share the host's network stack, removing
isolation and exposing every port directly. A dedicated **bridge network**
(`inception`) isolates the services, lets them reach each other by service name
(e.g. `mariadb`, `wordpress`), and exposes nothing to the outside except the
single published port 443 on NGINX. Host networking (as well as `--link` /
`links`) is forbidden by the subject and avoided here.

**Docker Volumes vs Bind Mounts**
A bind mount maps an arbitrary host path directly into a container and is tied
to the host's directory structure. A **named volume** is managed by Docker,
declared in the compose file, and referenced by name — which is what the subject
requires. Both WordPress files and the database use named volumes; their data is
persisted under `~/data` so it survives container restarts and crashes, and is
only removed by an explicit `make clean`/`make fclean`.
