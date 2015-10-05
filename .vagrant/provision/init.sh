#!/usr/bin/env bash

echo ""
echo "  This is going to take a while."
echo "  You should consider making yourself a beverage."
echo "  -----------------------------------------------"
echo ""

echo "Upgrading all software to latest version..."
apt-get update -y >/dev/null 2>&1
apt-get dist-upgrade -y >/dev/null 2>&1

# Install utilities, server software and language engines.
echo "Installing required software to run a web server..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    whiptail \
    wget \
    curl \
    build-essential \
    openssl \
    git-flow \
    nginx \
    mysql-server \
    npm \
    redis-server \
    default-jre >/dev/null 2>&1

# Allow the root MySQL user to be accessed from the host machine.
mysql -u root -e "UPDATE mysql.user SET Host = '%' WHERE User = 'root' AND Host = 'localhost'"

# Link Git's diff-highlight script for SuperSexyDiff-time!
ln -s /usr/share/doc/git/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight >/dev/null 2>&1
chmod +x /usr/local/bin/diff-highlight >/dev/null 2>&1

# Install PHP
echo "Installing PHP and common extensions..."
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
    php5-xsl >/dev/null 2>&1

# Setup PHP and its extensions
echo "Tweaking PHP configuration for Vagrant..."
sed -i -e s/www-data/vagrant/g /etc/php5/fpm/pool.d/www.conf >/dev/null 2>&1
(cd /etc/php5/fpm/conf.d; ln -s ../../mods-available/mcrypt.ini 15-mcrypt.ini) >/dev/null 2>&1
(cd /etc/php5/cli/conf.d; ln -s ../../mods-available/mcrypt.ini 15-mcrypt.ini) >/dev/null 2>&1

# Install PHP's Composer
echo "Installing Composer..."
which composer >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    wget -O /usr/local/bin/composer https://getcomposer.org/composer.phar >/dev/null 2>&1
    chmod +x /usr/local/bin/composer >/dev/null 2>&1
    # Make sure that Composer's cache directory is owned by the right user.
    sudo -u vagrant -H mkdir -p /home/vagrant/.composer/cache >/dev/null 2>&1
else
    echo "Composer already installed. Upgrading..."
    composer self-update >/dev/null 2>&1
fi

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
if [[ ! -d /opt/phpmyadmin ]]; then
    PMA_VERSION="4.5.0.2" >/dev/null 2>&1
    PMA_NAME="phpMyAdmin-${PMA_VERSION}-english" >/dev/null 2>&1
    wget -O /tmp/pma.tar.bz2 https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/${PMA_NAME}.tar.bz2 >/dev/null 2>&1
    (cd /tmp; tar xjf pma.tar.bz2) >/dev/null 2>&1
    mv /tmp/$PMA_NAME /opt/phpmyadmin >/dev/null 2>&1
    mysql -u root -e "CREATE DATABASE phpmyadmin" >/dev/null 2>&1
    mysql -u root -e "CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'phpmyadmin'" >/dev/null 2>&1
    mysql -u root -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'localhost'" >/dev/null 2>&1
    mysql -u root < /opt/phpmyadmin/sql/create_tables.sql >/dev/null 2>&1
else
    echo "phpMyAdmin already installed..."
fi

# Setup Nginx
echo "Configuring Nginx for Vagrant..."
sed -i -e s/www-data/vagrant/g /etc/nginx/nginx.conf >/dev/null 2>&1

# Alias NodeJS
ln -s `which nodejs` /usr/local/bin/node >/dev/null 2>&1

# Install Docker.
echo "Installing Docker..."
which docker >/dev/null 2>&1 || curl -sSL https://get.docker.com/ | sh >/dev/null 2>&1
usermod -aG docker vagrant >/dev/null 2>&1

# Install Docker Composer
echo "Installing Docker Compose..."
which docker-compose >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    DOCKER_COMPOSE_LATEST=$(git ls-remote --tags git://github.com/docker/compose.git | sort -t '/' -k 3 -V | grep -v "rc" | tail -n 1)
    DOCKER_COMPOSE_LATEST=${DOCKER_COMPOSE_LATEST##*/}
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_LATEST}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose >/dev/null 2>&1
    chmod +x /usr/local/bin/docker-compose >/dev/null 2>&1
fi

# Remove any packages that are no longer required.
echo "Cleaning up..."
apt-get autoremove -y >/dev/null 2>&1
