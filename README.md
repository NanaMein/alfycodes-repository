# Ghost_CMS

Production **Docker Compose** deployment of [Ghost CMS](https://ghost.org/) powering **[alfycodes.me](https://alfycodes.me)** — a personal site for projects, tech writing, and career journey documentation. It demonstrates two deployment options: use an existing host reverse proxy, or opt into the bundled Docker Nginx and Certbot.

## Purpose

This repo runs a live Ghost blog in production and showcases two reverse-proxy arrangements. The site at [alfycodes.me](https://alfycodes.me) hosts:

- **Projects** — working systems with real tradeoffs (FastAPI, Docker, infrastructure)
- **Stories** — career rants, tech experiments, honest posts about figuring things out
- **Tech Lab** — technical deep dives and tips

It's a one-person workshop: build, break, document. Not polished case studies — real systems with real tradeoffs.

## Quick start: use an existing reverse proxy

```bash
# 1. Copy and fill in environment variables
cp .env.example .env

# 2. Start Ghost and MySQL (the default; no bundled Nginx or Certbot)
docker compose up -d
```

Ghost is available on `127.0.0.1:2368`, so an Nginx instance already running on the VPS can reverse-proxy to it. MySQL stays on the private Compose network and is not published to the host.

## Alternative: use the bundled Docker Nginx

To demonstrate or deploy the self-contained proxy option, enable the `docker-nginx` profile:

```bash
docker compose --profile docker-nginx up -d
```

This starts the same Ghost and MySQL services plus Docker Nginx and Certbot. Use this option only when host ports 80 and 443 are available; do not enable it alongside a host Nginx already listening on those ports. For first-time TLS setup, configure `CERTBOT_EMAIL` in `.env` and run `./scripts/init-letsencrypt.sh`.

To stop the bundled proxy services while leaving Ghost and MySQL running:

```bash
docker compose --profile docker-nginx stop nginx certbot
```

## Architecture

```
Existing host Nginx ─┐
                     ├─→ Ghost 127.0.0.1:2368 → MySQL 8.4
Docker Nginx profile ┘        (shared Compose services)
       ↕
    Certbot
```

| Component | Details |
|---|---|
| **Ghost** | `ghost:latest`, binds to `127.0.0.1:2368` (localhost only) |
| **MySQL** | 8.4, data in `ghost_cms_postgres_data` volume |
| **Nginx** | Optional `docker-nginx` profile; Alpine, `network_mode: host`, reverse proxy with TLS |
| **Certbot** | Optional `docker-nginx` profile; renews certificates; manual renewal via script |
| **SMTP** | Brevo (`smtp-relay.brevo.com:587`) for email |
| **TLS** | Let's Encrypt, TLSv1.2/1.3 |

## What's in the repo

| Path | Purpose |
|---|---|
| `docker-compose.yml` | Shared MySQL/Ghost services; Nginx and Certbot are opt-in via `docker-nginx` profile |
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

For the bundled Docker Nginx option, the Certbot container renews certificates periodically. The renewal script can also be scheduled daily:

```bash
0 3 * * * /path/to/scripts/renew-certs.sh >> /var/log/letsencrypt-renew.log 2>&1
```

## Requirements

- Docker + Docker Compose v2
- Ports 80/443 must be free only when using the optional Docker Nginx profile
- `.env` filled in (copy from `.env.example`)
- Bash (for scripts)

## Ghost theme

Looking for the theme used on this site? Check it out here: [placeholder-url]

## Operational notes

- Ghost content volume: `ghost_cms_content_data` (persists posts, images, themes)
- MySQL data volume: `ghost_cms_postgres_data` (naming is a legacy quirk — it stores MySQL data)
- No application code lives here — this is purely infrastructure for running Ghost
