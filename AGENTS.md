# AGENTS.md

- No application code, package manifests, or CI/build/test scripts exist here. This repo is a **Docker Compose deployment for Ghost CMS on a VPS** — do not assume a Node/Python/Rails project or any dev commands.
- `docker-compose.yml` is the source of truth for infrastructure. `docs/scratch_and_draft.md` is historical notes only.
- **Database is MySQL 8.4** (decided; not up for debate). Ghost connects to MySQL via Docker networking.
- VPS already runs **CrowdSec** and **UFW**. New config must integrate with these, not replace them.
- Ghost domain: **`alfycodes.me`**.
- Ghost binds to **`127.0.0.1:2368`** — the host reverse proxy or optional Docker Nginx can proxy to it. Do not expose Ghost ports publicly.
- The default Compose mode runs **Ghost + MySQL only**, for use behind the VPS's existing Nginx/reverse proxy. Ghost binds to `127.0.0.1:2368`; MySQL is not published.
- Optional `docker-nginx` Compose profile adds Docker Nginx (`network_mode: host`) and Certbot. Use this alternative only when host ports 80/443 are available; it conflicts with any host proxy already listening there. Do not stop or replace the VPS's host Nginx unless explicitly requested.
- Nginx config: `nginx/conf.d/default.conf`. Certs stored in `certbot-certs` Docker volume.
- First-time cert setup: `./scripts/init-letsencrypt.sh` (requires `CERTBOT_EMAIL` in `.env`).
- Auto-renewal: `./scripts/renew-certs.sh` — run via cron (e.g. `0 3 * * *`). Uses Certbot standalone mode (briefly pauses Nginx).
- `.env.example` lists required variables; copy to `.env` on the VPS and fill in real values. Never commit `.env`.
- `DOMAIN` in `.env` drives Ghost URL, Nginx `server_name`, and Let's Encrypt. Change it for a different domain.
- Email uses **Brevo SMTP** (`smtp-relay.brevo.com:587`). Config is in the compose file via environment variables.
- The compose file names a volume `ghost_cms_postgres_data` but it stores **MySQL** data — this is a naming inconsistency, not a clue to switch databases.
- Treat anything produced here as **production-ready** until explicitly approved. No destructive infrastructure changes without confirmation.
