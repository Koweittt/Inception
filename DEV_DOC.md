# DEV_DOC — Developer Documentation

This document explains how a developer can set up, build, run, and maintain the
**Inception** project from scratch.

---

## 1. Overview & architecture

The project builds a Docker Compose stack of three custom-built images (no
pre-built images are pulled except the Debian base):

```
                       WWW
                        │  443 (HTTPS, TLSv1.2/1.3)
                        ▼
        ┌───────────────────────────────────────┐
        │   Docker network "inception" (bridge)  │
        │                                        │
        │  nginx ──9000──▶ wordpress ──3306──▶ mariadb
        └───────────────────────────────────────┘
              │                  │                 │
        wordpress vol      wordpress vol       mariadb vol
                          (shared)
```

- **nginx** — Debian + NGINX, TLS termination, reverse proxy to php-fpm.
- **wordpress** — Debian + php-fpm + WordPress + wp-cli.
- **mariadb** — Debian + MariaDB server.

Each service has its own `Dockerfile` under
`srcs/requirements/<service>/Dockerfile`, built by `docker-compose.yml`, which
is itself invoked by the `Makefile`.

---

## 2. Prerequisites

- A Linux host (or VM) with:
  - **Docker Engine** + **Docker Compose v2** (`docker compose`)
  - **make**
  - `sudo` rights (used by `make fclean`)
- Your domain mapped locally. Add to `/etc/hosts`:
  ```
  127.0.0.1   abignals.42.fr
  ```

---

## 3. Setting up the environment from scratch

The repository intentionally **does not** ship `srcs/.env` or the `secrets/`
folder (both are git-ignored). You must create them.

### 3.1 Create the secrets

At the **project root**, create a `secrets/` folder with three files:

```
secrets/
├── db_root_password.txt   # MariaDB root password
├── db_password.txt        # MariaDB wordpress-user password
└── credentials.txt        # WordPress admin password
```

Each file contains **only the password**, on a single line, no trailing spaces.

### 3.2 Create the environment file

Create `srcs/.env` with the non-secret variables consumed by the containers:

```dotenv
# Domain
DOMAIN_NAME=abignals.42.fr

# MariaDB / WordPress database
SQL_DATABASE=wordpress
SQL_USER=wp_user

# WordPress site
WP_TITLE=Inception

# WordPress administrator (MUST NOT contain "admin"/"administrator")
WP_ADMIN_USER=bossman
WP_ADMIN_EMAIL=bossman@abignals.42.fr

# WordPress second (author) user
WP_USER=redactor
WP_USER_EMAIL=redactor@abignals.42.fr
WP_USER_PASSWORD=change_me
```

> ⚠️ `WP_ADMIN_USER` must **not** contain `admin`/`Admin`/`administrator` — this
> is a hard project requirement.
>
> Passwords used by MariaDB and by the WordPress admin come from **secrets**,
> not from `.env`.

### 3.3 Where each variable/secret is used

| Name | Source | Consumed by |
|------|--------|-------------|
| `SQL_DATABASE`, `SQL_USER` | `.env` | mariadb `create_db.sh`, wordpress `auto_config.sh` |
| `db_password.txt` | secret | mariadb (user pwd) + wordpress (DB connection) |
| `db_root_password.txt` | secret | mariadb (root pwd) |
| `credentials.txt` | secret | wordpress admin password |
| `DOMAIN_NAME`, `WP_TITLE`, `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASSWORD` | `.env` | wordpress `auto_config.sh` |

---

## 4. Building and launching

From the project root:

```bash
make            # mkdir ~/data/{wordpress,mariadb} + docker compose up -d --build
```

This:
1. Creates the host data directories `~/data/wordpress` and `~/data/mariadb`.
2. Builds the three images.
3. Starts the containers detached.

On first boot:
- **mariadb** (`create_db.sh`) creates the database and the WordPress user,
  sets the root password, then execs `mysqld_safe`.
- **wordpress** (`auto_config.sh`) waits for MariaDB, runs `wp config create`,
  `wp core install`, creates the second user, then execs `php-fpm -F`.
- **nginx** starts and serves `https://abignals.42.fr`.

---

## 5. Managing containers and volumes

| Task | Command |
|------|---------|
| Status of containers | `make status` |
| Live logs (all) | `make logs` |
| Logs of one service | `docker compose -f srcs/docker-compose.yml logs -f wordpress` |
| Open a shell in a container | `docker exec -it wordpress sh` |
| Stop / start (keep data) | `make stop` / `make start` |
| Down (remove containers) | `make down` |
| Rebuild | `make re` |
| Remove images + volumes | `make clean` |
| Full wipe (also `~/data`) | `make fclean` |
| List volumes | `docker volume ls` |
| Inspect a volume | `docker volume inspect inception_wordpress` |
| List the network | `docker network ls` \| `docker network inspect inception_inception` |

---

## 6. Data storage & persistence

- Two **named volumes** are declared in `docker-compose.yml`:
  - `mariadb`  → database files (`/var/lib/mysql`)
  - `wordpress` → website files (`/var/www/wordpress`, shared with nginx)
- Both use the `local` driver with `driver_opts` (`type: none, o: bind`) so the
  data actually lives on the host under:
  ```
  ~/data/mariadb      # MariaDB data
  ~/data/wordpress    # WordPress files
  ```
- **Persistence:** because data is stored in these host-backed volumes, stopping
  or restarting the containers (`make stop/start`, reboot, crash-restart) keeps
  all content. Data is only destroyed by `make clean` (`-v`) or `make fclean`.

> The install scripts are idempotent: `create_db.sh` skips DB creation if the
> database already exists, and `auto_config.sh` skips setup if `wp-config.php`
> already exists. To force a clean reinstall, run `make fclean` then `make`.

---

## 7. Repository layout

```
.
├── Makefile
├── secrets/                      # git-ignored (create locally)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                      # git-ignored (create locally)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/   (Dockerfile, conf/50-server.cnf, conf/create_db.sh)
        ├── nginx/     (Dockerfile, conf/nginx.conf)
        └── wordpress/ (Dockerfile, conf/auto_config.sh)
```

---

## 8. Troubleshooting

- **`make` fails on volume creation** — ensure `~/data/wordpress` and
  `~/data/mariadb` exist (the Makefile creates them; check host permissions).
- **WordPress can't reach the DB** — check `db_password.txt` matches what
  MariaDB was initialised with; if you changed it after first boot, run
  `make fclean && make`.
- **Browser TLS warning** — expected (self-signed certificate).
- **Nothing on port 80** — by design; the stack only answers on 443.
