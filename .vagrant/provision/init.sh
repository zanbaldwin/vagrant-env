#!/usr/bin/env bash
apt-get update -y
apt-get dist-upgrade -y

# Install utilities, server software and language engines.
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    whiptail \
    wget \
    curl \
    build-essential \
    git-flow \
    nginx \
    mysql-server \
    nodejs \
    redis-server \
    default-jre

# Link Git's diff-highlight script for SuperSexyDiff-time!
ln -s /usr/share/doc/git/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
chmod +x /usr/local/bin/diff-highlight

# Install PHP
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php5-cli \
    php5-common \
    php5-curl \
    php5-dev \
    php5-fpm \
    php5-gd \
    php5-gmp \
    php5-imagick \
    php5-intl \
    php5-json \
    php5-mcrypt \
    php5-mysqlnd \
    php5-readline \
    php5-redis \
    php5-xdebug \
    php5-xsl

# Setup PHP and its extensions
sed -i -e s/www-data/vagrant/g /etc/php5/fpm/pool.d/www.conf
(cd /etc/php5/fpm/conf.d; ln -s ../../mods-available/mcrypt.ini 15-mcrypt.ini)
(cd /etc/php5/cli/conf.d; ln -s ../../mods-available/mcrypt.ini 15-mcrypt.ini)

# Install PHP's Composer
which composer
if [[ $? -ne 0 ]]; then
    wget -O /usr/local/bin/composer https://getcomposer.org/composer.phar
    chmod +x /usr/local/bin/composer
else
    composer self-update
fi

# Install phpMyAdmin
if [[ ! -d /opt/phpmyadmin ]]; then
    PMA_VERSION="4.5.0.2"
    PMA_NAME="phpMyAdmin-${PMA_VERSION}-english"
    wget -O /tmp/pma.tar.bz2 https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/${PMA_NAME}.tar.bz2
    (cd /tmp; tar xjf pma.tar.bz2)
    mv /tmp/$PMA_NAME /opt/phpmyadmin
    mysql -u root -e "CREATE DATABASE phpmyadmin"
    mysql -u root -e "CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'phpmyadmin'"
    mysql -u root -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'localhost'"
    mysql -u root < /opt/phpmyadmin/sql/create_tables.sql
fi

# Setup Nginx
sed -i -e s/www-data/vagrant/g /etc/nginx/nginx.conf

# Alias NodeJS
ln -s `which nodejs` /usr/local/bin/node

# Install Docker.
which docker || curl -sSL https://get.docker.com/ | sh
usermod -aG docker vagrant

# Install Docker Composer
which docker-compose
if [[ $? -ne 0 ]]; then
    DOCKER_COMPOSE_LATEST=$(git ls-remote --tags git://github.com/docker/compose.git | sort -t '/' -k 3 -V | grep -v "rc" | tail -n 1)
    DOCKER_COMPOSE_LATEST=${DOCKER_COMPOSE_LATEST##*/}
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_LATEST}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Remove any packages that are no longer required.
apt-get autoremove -y
