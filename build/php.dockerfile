# syntax=docker/dockerfile:1.3-labs
FROM php:8.3-fpm-bookworm

# make PHP extension installation easier
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

SHELL ["/bin/bash", "-c"]

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
echo "upload_max_filesize=64M" >> "$PHP_INI_DIR/php.ini"
echo "post_max_size=64M" >> "$PHP_INI_DIR/php.ini"
# enhanced xdebug
echo "xdebug.cli_color=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# MAIL
echo "mailhub=mail:1025" >> /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=NO" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

echo "pm.status_path = /status" >>/usr/local/etc/php-fpm.d/www.conf
echo "pm.status_listen = 127.0.0.1:9001" >>/usr/local/etc/php-fpm.d/www.conf
EOF

COPY my.cnf /root/.my.cnf
RUN chmod 0644 /root/.my.cnf

# expose FPM
EXPOSE  9000

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
		CMD REQUEST_METHOD=GET SCRIPT_NAME=/status SCRIPT_FILENAME=/status cgi-fcgi -bind -connect 127.0.0.1:9001

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
