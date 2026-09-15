# Ghost_CMS

Production **Docker Compose** deployment of [Ghost CMS](https://ghost.org/) powering **[alfycodes.me](https://alfycodes.me)** — a personal site for projects, tech writing, and career journey documentation.

## Purpose

This repo exists to run a live Ghost blog in production. The site at [alfycodes.me](https://alfycodes.me) hosts:

- **Projects** — working systems with real tradeoffs (FastAPI, Docker, infrastructure)
- **Stories** — career rants, tech experiments, honest posts about figuring things out
- **Tech Lab** — technical deep dives and tips

It's a one-person workshop: build, break, document. Not polished case studies — real systems with real tradeoffs.

## Quick start

```bash
# 1. Copy and fill in environment variables
cp .env.example .env

# 2. Stop host Nginx/Certbot on ports 80/443 (they conflict with Docker Nginx)
sudo systemctl stop nginx certbot

# 3. Obtain TLS certificate
./scripts/init-letsencrypt.sh

# 4. Bring everything up
docker compose up -d
```

## Architecture

```
Internet → :80/:443 → Nginx (Docker) → Ghost :2368 → MySQL 8.4
                                     ↕
                             Certbot (auto-renew)
```

| Component | Details |
|---|---|
| **Ghost** | `ghost:latest`, binds to `127.0.0.1:2368` (localhost only) |
| **MySQL** | 8.4, data in `ghost_cms_postgres_data` volume |
| **Nginx** | Alpine, `network_mode: host`, reverse proxy with TLS |
| **Certbot** | Auto-renews every 12h; manual renewal via script |
| **SMTP** | Brevo (`smtp-relay.brevo.com:587`) for email |
| **TLS** | Let's Encrypt, TLSv1.2/1.3 |

## What's in the repo

| Path | Purpose |
|---|---|
| `docker-compose.yml` | All services: MySQL, Ghost, Nginx, Certbot |
| `nginx/conf.d/default.conf` | Reverse proxy config (HTTP → HTTPS, ACME challenge) |
| `.env.example` | Required environment variables |
| `scripts/init-letsencrypt.sh` | First-time TLS certificate request |
| `scripts/renew-certs.sh` | Certificate renewal (run via cron) |
| `AGENTS.md` | Agent instructions for working in this repo |
| `docs/scratch_and_draft.md` | Historical planning notes |

## Environment variables

Copy `.env.example` to `.env` and fill in:

| Variable | Description |
|---|---|
| `DOMAIN` | Ghost domain (default: `alfycodes.me`) |
| `CERTBOT_EMAIL` | Let's Encrypt notification email |
| `MYSQL_DB` | MySQL database name |
| `MYSQL_USER` | MySQL username |
| `MYSQL_PASSWORD` | MySQL password |
| `MYSQL_ROOT_PASSWORD` | MySQL root password |
| `SMTP_FROM` | Sender address (e.g. `"AlfyCodes <noreply@alfycodes.me>"`) |
| `SMTP_USER` | Brevo SMTP login |
| `SMTP_PASS` | Brevo SMTP key |

## Cron setup

Auto-renew Let's Encrypt certificates daily:

```bash
0 3 * * * /path/to/scripts/renew-certs.sh >> /var/log/letsencrypt-renew.log 2>&1
```

## Requirements

- Docker + Docker Compose v2
- Ports 80/443 free (stop host Nginx/Certbot before first deploy)
- `.env` filled in (copy from `.env.example`)
- Bash (for scripts)

## Ghost theme

Looking for the theme used on this site? Check it out here: [placeholder-url]

## Docker Compose without Nginx

If you want to run Ghost without Nginx (you already have your own reverse proxy), here's a lightweight Docker Compose setup: [placeholder-url]

## Operational notes

- Ghost content volume: `ghost_cms_content_data` (persists posts, images, themes)
- MySQL data volume: `ghost_cms_postgres_data` (naming is a legacy quirk — it stores MySQL data)
- No application code lives here — this is purely infrastructure for running Ghost
