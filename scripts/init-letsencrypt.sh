#!/bin/bash
set -euo pipefail

# First-time Let's Encrypt certificate request.
# Prerequisites: .env filled in, host Nginx/Certbot stopped (ports 80/443 free).
#
# Usage:  ./scripts/init-letsencrypt.sh

DOMAIN="alfycodes.me"
EMAIL="${CERTBOT_EMAIL:-}"  # set in .env or export before running
WEBROOT="/var/www/certbot"
LETSENCRYPT_DIR="/etc/letsencrypt/live/${DOMAIN}"

if [ -z "$EMAIL" ]; then
  echo "ERROR: CERTBOT_EMAIL not set. Add it to .env or export it."
  exit 1
fi

echo "==> Starting Nginx (HTTP-only, serving ACME challenge)..."
docker compose up -d nginx

echo "==> Waiting for Nginx to be ready..."
sleep 3

echo "==> Requesting certificate for ${DOMAIN}..."
docker compose run --rm certbot certbot certonly \
  --webroot \
  --webroot-path="${WEBROOT}" \
  --email "${EMAIL}" \
  --agree-tos \
  --no-eff-email \
  -d "${DOMAIN}" \
  -d "www.${DOMAIN}"

echo "==> Reloading Nginx with TLS config..."
docker compose exec nginx nginx -s reload

echo "==> Done. Certificate obtained at ${LETSENCRYPT_DIR}"
echo "    Set up cron for auto-renewal:  0 3 * * * $(pwd)/scripts/renew-certs.sh"
