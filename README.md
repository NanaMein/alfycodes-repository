# Ghost_CMS

This repository is currently a **draft** for deploying **Ghost CMS** using **Docker Compose** on a **remote VPS**.

Your VPS already has **Nginx + Certbot** (TLS), plus **CrowdSec** and **UFW** for security hardening, and the intended Ghost domain is **`alfycodes.me`**.

## What’s here right now

- `docs/scratch_and_draft.md`: initial notes about a secured Docker Compose deployment and database considerations.

## Next steps

If you add actual runtime/config files (e.g., `docker-compose.yml`, `.env.example`, reverse proxy/SSL, backups), this repo should be updated with the verified commands and operational runbook so agents can follow them without guessing.

This repo now includes a production-oriented starting point for **Ghost + MySQL** via Docker Compose (with Ghost bound to **127.0.0.1** so your existing VPS Nginx can handle TLS + public routing).


## Source of truth

- See `docs/scratch_and_draft.md`
