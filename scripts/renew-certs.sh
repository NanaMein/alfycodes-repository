#!/bin/bash
set -euo pipefail

# Renew Let's Encrypt certificates and reload Nginx.
# Run via cron, e.g.:  0 3 * * * /path/to/scripts/renew-certs.sh
#
# This runs Certbot in standalone mode (briefly stops Nginx on port 80).

echo "==> Pausing Nginx..."
docker compose --profile docker-nginx stop nginx

echo "==> Running Certbot renewal..."
docker compose --profile docker-nginx run --rm certbot certbot renew --quiet

echo "==> Restarting Nginx..."
docker compose --profile docker-nginx start nginx

echo "==> Renewal complete."
