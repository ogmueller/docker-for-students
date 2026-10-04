#!/usr/bin/env bash
#
# OPTIONAL: enable HTTPS on https://localhost:8443
#
# mkcert has to be installed to use this script.
# for more information and installation instructions,
# read https://github.com/FiloSottile/mkcert
# and run "mkcert -install" once before using this script.
#

set -euo pipefail

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P)"
CERT_PATH="${SCRIPT_PATH}/nginx"

mkcert \
    -cert-file "${CERT_PATH}/app.crt" \
    -key-file "${CERT_PATH}/app.key" \
    dhbw.test \
    '*.dhbw.test' \
    localhost \
    127.0.0.1 \
    ::1

cat "$(mkcert -CAROOT)/rootCA.pem" >> "${CERT_PATH}/app.crt"

# activate the HTTPS server block for nginx
cp "${CERT_PATH}/ssl.conf.dist" "${CERT_PATH}/ssl.conf"

echo
echo "HTTPS is set up. Now run:  docker compose restart web"
echo "Then open https://localhost:8443"
