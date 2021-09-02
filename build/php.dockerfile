FROM php:8.0-fpm-bullseye

RUN     apt-get update \
    &&  apt-get install --no-install-recommends -y \
        git \
        libicu-dev \
        libicu67 \
        libpng-dev \
        libpng-tools \
        libzip-dev \
        libzip4 \
        mariadb-client \
        mycli \
        tar \
        vim \
        zip \
# \
# OPTIONAL \
# \
        # for bz2 \
        libbz2-1.0 \
        libbz2-dev \
        bzip2 \
        # for enchangt \
        libenchant-2-2 \
        libenchant-2-dev \
        # for gmagick \
        graphicsmagick \
        libgraphicsmagick1-dev \
        # for gmp \
        libgmp3-dev \
        # for gnupg \
        libgpgme11 \
        libgpgme-dev \
        # for imap \
        libc-client2007e \
        libc-client-dev \
        libkrb5-dev \
        # for pspall \
        libaspell15 \
        libpspell-dev \
        aspell-en \
        aspell-de \
        # for snmp \
        libsnmp40 \
        libnetsnmptrapd40 \
        procps \
        libsnmp-dev \
        # for tidy \
        libtidy5deb1 \
        libtidy-dev \
        # for xsl \
        libxslt1.1 \
        libxslt-dev \
        # for yaml \
        libyaml-0-2 \
        libyaml-dev \
    &&  docker-php-ext-configure zip \
# \
# OPTIONAL \
# \
    &&  docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    &&  docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        sockets \
        zip \
# \
# OPTIONAL \
# \
        bcmath \
        bz2 \
        calendar \
        enchant \
        exif \
        gettext \
        gmp \
        imap \
        pspell \
        sysvmsg \
        sysvsem \
        sysvshm \
        shmop \
        snmp \
        soap \
        tidy \
        xsl \
    &&  pecl install \
        apcu \
        xdebug \
# \
# OPTIONAL \
# \
        gmagick-beta \
        gnupg \
        mailparse \
        yaml \
    &&  docker-php-ext-enable \
        apcu \
        xdebug \
# remove all dev libraries, because we only need those to build extensions, but not to run them.
# beware that you still need the non-dev counterparts, if they exist.
    &&  apt-get -y remove --purge \
        libicu-dev \
        libpng-dev \
        libzip-dev \
        libbz2-dev \
        libenchant-2-dev \
        libgraphicsmagick1-dev \
        libgmp3-dev \
        libgpgme-dev \
        libc-client-dev \
        libkrb5-dev \
        libpspell-dev \
        libsnmp-dev \
        libtidy-dev \
        libxslt-dev \
        libyaml-dev \
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

# install composer
COPY    --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV     COMPOSER_HOME /tmp/.composer

# expose FPM
EXPOSE  9000

WORKDIR /application

# vim: syntax=Dockerfile ts=4 sw=4 et sr softtabstop=4 autoindent
