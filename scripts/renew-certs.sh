#!/bin/bash
set -euo pipefail

# Renew Let's Encrypt certificates and reload Nginx.
# Run via cron, e.g.:  0 3 * * * /path/to/scripts/renew-certs.sh
#
# This runs Certbot in standalone mode (briefly stops Nginx on port 80).

echo "==> Pausing Nginx..."
docker compose stop nginx

echo "==> Running Certbot renewal..."
docker compose run --rm certbot certbot renew --quiet

echo "==> Restarting Nginx..."
docker compose start nginx

echo "==> Renewal complete."
