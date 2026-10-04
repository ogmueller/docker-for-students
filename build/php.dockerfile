# syntax=docker/dockerfile:1.6
FROM php:8.4-fpm-trixie

LABEL maintainer="Oliver G. Mueller <oliver@teqneers.de>"

# easier PHP extension installation
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN <<EOI
apt-get update
apt-get install --no-install-recommends -y \
      ca-certificates \
      git \
      mariadb-client \
      tar \
      zip \
      vim-tiny \
      libfcgi-bin \
      msmtp
rm -rf /var/lib/apt/lists/*
EOI

# ---- PHP extensions ----
RUN <<EOI
install-php-extensions \
      @composer \
      imap \
      gd \
      intl \
      mysqli \
      opcache \
      pcntl \
      pdo_mysql \
      sockets \
      zip \
      apcu \
      xdebug \
      bcmath \
      bz2 \
      calendar \
      exif
EOI

# ---- PHP extensions for developement ----
RUN install-php-extensions \
      apcu \
      xdebug

# ---- PHP extensions optional ----
RUN install-php-extensions \
      bcmath \
      bz2 \
      calendar \
      exif

# ---- PHP config ----
RUN <<EOI
mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
cat >> "$PHP_INI_DIR/php.ini" <<'EOF'
# enable bigger uploads
upload_max_filesize=64M
post_max_size=64M
EOF
EOI

# xdebug: installed, but disabled by default unless XDEBUG_MODE is set.
# In docker-compose, set:
#   XDEBUG_MODE=debug,develop
# Or keep it off:
#   XDEBUG_MODE=off
COPY <<'EOI' /usr/local/etc/php/conf.d/99-xdebug.ini
xdebug.mode=${XDEBUG_MODE}
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
xdebug.cli_color=1
EOI

# ---- Mail (MailHog/Mailpit style) ----
# msmtp provides sendmail compatibility for PHP's mail().
# Expects a compose service "mail" listening on 1025 (no TLS).
COPY <<'EOI' /etc/msmtprc
defaults
auth           off
tls            off
account        local
host           mail
port           1025
from           noreply@example.test
account default : local
EOI

RUN <<EOI
chmod 0644 /etc/msmtprc
printf '%s\n' 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/99-mail.ini
EOI

# ---- PHP-FPM health endpoints (robust) ----
COPY <<'EOI' /usr/local/etc/php-fpm.d/zz-health.conf
[www]
pm.status_path = /status
ping.path = /ping
ping.response = pong
EOI

# Provide a safe default for xdebug (off). Override in compose when needed.
ENV XDEBUG_MODE=off

COPY my.cnf /root/.my.cnf
RUN chmod 0644 /root/.my.cnf

# expose FPM
EXPOSE  9000

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD REQUEST_METHOD=GET SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q "pong"

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
