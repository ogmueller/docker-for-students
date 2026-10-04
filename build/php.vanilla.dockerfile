# syntax=docker/dockerfile:1.6
FROM php:8.4-fpm-trixie

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
      msmtp
rm -rf /var/lib/apt/lists/*
EOI

# ---- PHP extensions ----
RUN install-php-extensions \
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
# development
      apcu \
      xdebug \
# optional
      bcmath \
      bz2 \
      calendar \
      csv \
      decimal \
      enchant \
      event \
      exif \
      gettext \
      gmagick \
      gmp \
      gnupg \
      ldap \
      lzf \
      mailparse \
      pspell \
      sysvmsg \
      sysvsem \
      sysvshm \
      shmop \
      snmp \
      soap \
      ssh2 \
      tidy \
      uuid \
      xsl \
      yaml

# ---- PHP config ----
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# xdebug: installed, but disabled by default unless XDEBUG_MODE is set
COPY <<'EOI' /usr/local/etc/php/conf.d/99-xdebug.ini
xdebug.mode=${XDEBUG_MODE}
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
EOI

# ---- Mail (Mailpit) ----
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

ENV XDEBUG_MODE=off

COPY my.cnf /root/.my.cnf
RUN chmod 0644 /root/.my.cnf

# expose FPM
EXPOSE  9000

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
