FROM php:8.0-fpm-bullseye

# make PHP extension installation easier
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN     apt-get update \
    &&  apt-get install --no-install-recommends -y \
        git \
        mariadb-client \
        mycli \
        tar \
        vim \
        zip \
    &&  install-php-extensions \
        @composer \
        imap \
        gd \
        intl  \
        opcache \
        pcntl \
        pdo_mysql \
        sockets \
        zip \
# \
# DEVELOPMENT \
# \
        apcu \
        xdebug \
# \
# OPTIONAL \
# \
        bcmath \
        bz2 \
        calendar \
        exif \
    &&  apt-get autoremove -y \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*


RUN     mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    &&  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.coverage_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY my.cnf /root/.my.cnf
RUN		chmod 0644 /root/.my.cnf

# expose FPM
EXPOSE  9000

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
