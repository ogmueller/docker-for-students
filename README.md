# PHP - NGINX - MARIADB - MAIL

This projects provides all basic components to run PHP files on your local computer. [NGINX](http://nginx.org) is our webserver. It communicates with [PHP](https://php.net) using FastCGI (PHP-FPM). Our data will be stored in [MariaDB](http://mariadb.com/). In case we want to send out any email, we have [MailHog](https://github.com/mailhog/MailHog). It is our SMTP server and web UI for emails.

## Requirements

This setup requires [docker](https://www.docker.com) (version >= 3.4.0) to be installed on your system. Docker is a free software which isotates applications using container virtualization.

**Note:** You need to be in the root directory of this project to execute any `docker compose` command that is mentioned in this document.

## Setup

First we need to set various ports for e.g. webserver, mailserver, a.so.

- copy `.env.dist` to `.env`
- change ports in `.env` according to you needs. If you have a port conflict on your system, because any of the ports is used by another application, this is the place to change it.

## Docker

All necessary containers can be started with `docker compose up -d --build`. On the very first run, this might take a few minutes, because docker has to download images and setup and compile some tools.

Check your containers' status with `docker ps` or `docker ps -a`. It shows you if they are running and to find out about there current port bindings.

In case of failures or trouble use `docker compose logs` of `docker compose logs -f` to see logging output of the containers.

Use `docker compose down` to stop all containers, if you currently don't need them. This lowers CPU and memory consumption.

## Usage

All services are available on your localhost, e.g. if you have set HTTP_PORT to 8080, than you can reach the webserver with `http://localhost:8080/`. The following paragraphs assume the default port values used in `.env.dist`.

### PHP

There is a special folder for all your PHP files. It is the `/php` folder in the root of this project. Store all your PHP files in there to be able to access them with your browser (see next section). Your browser is going to talk to the web server, which will look for you PHP files. You have to use `.php` as a suffix to all your PHP files, so the web server knows how to execute them.

There is an example PHP script called `phpinfo.php` placed in this folder. If called in a browser, it will show you all kinds of [information about PHP](http://localhost:8080/php/phpinfo.php) itself and its envorinment.

### Web

The webserver and your PHP scripts are available by visiting `http://localhost:8080/`. There is an [overview page](http://localhost:8080) to this project. It explains and references to the other parts of the project. You can access your PHP files stored in `/php` folder with the very same path in the URL: http://localhost:8080/php/.

Port: HTTP_PORT

### Database

We are using MariaDB as our database management system. MariaDB is a fork of MySQL happened in 2009. This is important to know, because some command, folders, variable names, a.so. are still called mysql instead of mariadb. So don't get confused, when you see mysql in some places, it does refer to MariaDB.

If you want to *see* or operated on the database system, you can either access the database using a web UI called phpMyAdmin (see next chapter) or using a CLI client  `docker compose exec db mysql`. You can actually see the database content and its files in the `/data` folder. Do **not** modify any of those files, otherwise the database will be corrupt and disfunction.

It is also possible to install and use a desktop client. MariaDB published a list of [compatible clients](https://mariadb.com/kb/en/graphical-and-enhanced-clients/). Please note, that the default MariaDB port is 3306, but we have changed this to 8306 in `.env.dist`.

Port: DB_PORT

### phpMyAdmin

The easiest way to access, work with and manage our database management system is with [phpMyAdmin](http://localhost:8081/) using your web browser. phpMyAdmin allows you to select, insert, update and delete data. You can create and drop tables or backup and restore whole databases. It's [documentation](https://docs.phpmyadmin.net/en/latest/) will explain all features in detail.

Port: PHPMYADMIN_PORT

### Email

All emails should be caught by [mailhog](http://localhost:8025). We want to make sure, that we don't spam anybody by accident.

If necessary those emails can also be "released" in the UI and received by an email client.

Port: WEBMAIL_PORT



## Optional

### Debugging with PhpStorm

This section is optional and only applicable, if you are using PhpStorm IDE for development. Follow these brief steps to activate debugging withing your IDE.

- Required (enabled) plugins: Docker, PHP Docker
- [Preferences | Languages & Frameworks | PHP](jetbrains://PhpStorm/settings?name=Languages+%26+Frameworks--PHP)
  - add docker-compose CLI interpreter
    - service: php-test or php
    - environment variables: COMPOSE_PROJECT_NAME=dhbw
    - "Connect to existing container"
  - path mappings <Project root> -> /application
- [Preferences | Languages & Frameworks | PHP | Servers](jetbrains://PhpStorm/settings?name=Languages+%26+Frameworks--PHP--Servers)
  - Host: docker
  - Port 80
  - Debugger: Xdebug
  - Mapping: dhbw -> /application
