# USER_DOC — User Documentation

This document explains, in simple terms, how to use the **Inception** stack:
what it provides, how to start/stop it, how to reach the website and its admin
panel, where the credentials live, and how to check that everything is running.

---

## 1. What this stack provides

Inception is a small self-hosted infrastructure running entirely in Docker
containers on a single host. It serves a **WordPress** website behind an
encrypted (HTTPS) connection. It is made of three services:

| Service    | Role                                                                 |
|------------|----------------------------------------------------------------------|
| **NGINX**  | Web server. The **only** entry point, reachable on **HTTPS port 443** with TLSv1.2/TLSv1.3. |
| **WordPress + php-fpm** | The website itself and its PHP engine. Not directly exposed. |
| **MariaDB** | The database that stores all WordPress content (posts, users, settings). Not directly exposed. |

Data is persisted on the host in `~/data` so nothing is lost when containers
restart.

---

## 2. Starting and stopping the project

All commands are run from the **root of the project** (where the `Makefile` is).

| Action | Command |
|--------|---------|
| Build & start everything (in background) | `make` |
| Stop the containers (keeps data) | `make stop` |
| Start again after a stop | `make start` |
| Stop and remove the containers | `make down` |
| Rebuild from scratch | `make re` |
| See container status | `make status` |
| Follow live logs | `make logs` |
| Remove containers + images + volumes | `make clean` |
| Full cleanup (also deletes `~/data`) | `make fclean` |

> The very first `make` takes a few minutes: it builds the images and lets
> WordPress install itself automatically.

---

## 3. Accessing the website and the admin panel

Before accessing the site, make sure your domain points to your machine.
Add this line to `/etc/hosts` on the host:

```
127.0.0.1   abignals.42.fr
```

Then open in a browser:

- **Website:** `https://abignals.42.fr`
- **Admin panel:** `https://abignals.42.fr/wp-admin`

> The TLS certificate is **self-signed**, so the browser will show a security
> warning the first time. This is expected — click *Advanced → Proceed* to
> continue.

---

## 4. Locating and managing credentials

Credentials are **never** stored in the Git repository. They live locally in
two ignored locations:

### `secrets/` folder (at the project root)
| File | Contains |
|------|----------|
| `secrets/db_root_password.txt` | MariaDB **root** password |
| `secrets/db_password.txt`      | MariaDB **WordPress user** password |
| `secrets/credentials.txt`      | WordPress **administrator** password |

### `srcs/.env` file
Holds the non-secret configuration and the login names, for example:
`DOMAIN_NAME`, `SQL_DATABASE`, `SQL_USER`, `WP_TITLE`, `WP_ADMIN_USER`,
`WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`.

**To change a password:** edit the matching file in `secrets/`, then rebuild
with `make re` (a fresh database is only created on first run — see DEV_DOC for
details on resetting).

The WordPress site has **two users**:
- an **administrator** (username from `WP_ADMIN_USER`, password from `credentials.txt`),
- a **regular author** (username from `WP_USER`).

---

## 5. Checking that services are running correctly

1. **Container status** — all three must be `Up`:
   ```
   make status
   ```
   You should see `nginx`, `wordpress`, and `mariadb` running.

2. **Website reachable over HTTPS:**
   ```
   curl -kI https://abignals.42.fr
   ```
   A `HTTP/... 200` (or `30x` redirect) response means NGINX + WordPress work.

3. **Logs** — check for errors:
   ```
   make logs
   ```

4. **HTTP is refused** — the stack must only answer on 443. Port 80 should not
   serve anything.

If a container crashes, it is configured to **restart automatically**.
