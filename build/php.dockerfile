FROM php:8.0-fpm-buster

RUN     apt-get update \
    &&  apt-get install -y \
        git \
        libicu63 \
        libicu-dev \
        libpng-dev \
        libzip-dev \
        mariadb-client \
        mycli \
        tar \
        vim \
        zip \
	&&  docker-php-ext-configure zip \
    &&  docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        sockets \
        zip \
    &&  pecl install \
        apcu \
        xdebug \
    &&  docker-php-ext-enable \
        apcu \
        xdebug

RUN     mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    &&  echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.coverage_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    &&  echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY my.cnf /root/.my.cnf
RUN		chmod 0644 /root/.my.cnf

# install composer
COPY    --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV     COMPOSER_HOME /tmp/.composer

# expose FPM
EXPOSE  9000 

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent