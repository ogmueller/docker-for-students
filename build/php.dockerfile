# syntax=docker/dockerfile:1.6
FROM php:8.4-fpm-trixie

# make PHP extension installation easier
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN <<EOF
# ERROR HANDLING
set -o pipefail # trace ERR through pipes
set -o errtrace # trace ERR through 'time command' and other functions
set -o nounset  ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit  # stop on non zero return code
trap "exit" SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM

apt-get update
apt-get install --no-install-recommends -y \
        git \
        mariadb-client \
        ssmtp \
        tar \
        vim \
        zip \
        libfcgi-bin

install-php-extensions \
        @composer \
        imap \
        gd \
        intl  \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        sockets \
        zip

#
# DEVELOPMENT
#
install-php-extensions \
        apcu \
        xdebug
#
# OPTIONAL
#
install-php-extensions \
        bcmath \
        bz2 \
        calendar \
        exif

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
# ERROR HANDLING
set -o pipefail # trace ERR through pipes
set -o errtrace # trace ERR through 'time command' and other functions
set -o nounset  ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit  # stop on non zero return code
trap "exit" SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM


mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# enable bigger uploads
cat >> "$PHP_INI_DIR/php.ini" <<'EOI'
upload_max_filesize=64M
post_max_size=64M
EOI

# enhanced xdebug
cat >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini <<'EOI'
xdebug.cli_color=1
xdebug.idekey="PHPSTORM"
xdebug.client_host=host.docker.internal
EOI

# MAIL
cat >> /etc/ssmtp/ssmtp.conf <<'EOI'
mailhub=mail:1025
UseSTARTTLS=NO
FromLineOverride=YES
sendmail_path = "/usr/sbin/ssmtp -t"
EOI

cat >> /usr/local/etc/php-fpm.d/www.conf <<'EOI'
pm.status_path = /status
pm.status_listen = 127.0.0.1:9001
EOI

EOF

COPY my.cnf /root/.my.cnf
RUN chmod 0644 /root/.my.cnf

# expose FPM
EXPOSE  9000

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
		CMD REQUEST_METHOD=GET SCRIPT_NAME=/status SCRIPT_FILENAME=/status cgi-fcgi -bind -connect 127.0.0.1:9001

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
