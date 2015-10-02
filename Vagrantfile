# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/vivid64"
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.84.78"

  config.vm.synced_folder "code/", "/home/vagrant/code"

  ## If you want to store MySQL database on your host machine instead of inside the Vagrant environment,
  ## uncomment the next "synced_folder". If you do this, you won't lose database when you destroy the Vagrant
  ## machine (but your databases might get corrupted if you are using Windows).
  # config.vm.synced_folder "databases", "/var/lib/mysql"

  config.vm.provider "virtualbox" do |vb|
    # PHP's composer uses quite a lot of memory, increasing this helps but make sure you keep it within the
    # capabilities of the host machine you are running the Vagrant environment on.
    # If Composer keeps failing (return code 137) with the message "Killed" try increasing the memory.
    vb.memory = "2048"
  end

  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.vm.provision "shell", path: ".vagrant/provision/init.sh"
  # Copy Configuration Files into Vagrant Environment via SSH.
  config.vm.provision "file", source: ".vagrant/provision/config/my.cnf", destination: "/tmp/my.cnf"
  config.vm.provision "file", source: ".vagrant/provision/config/php.ini", destination: "/tmp/php.ini"
  config.vm.provision "file", source: ".vagrant/provision/config/pma-config.php", destination: "/tmp/pma-config.php"
  config.vm.provision "file", source: ".vagrant/provision/config/xdebug.ini", destination: "/tmp/xdebug.ini"
  config.vm.provision "file", source: ".vagrant/provision/config/nginx-site.conf", destination: "/tmp/nginx-site.conf"
  # Copy Utility Scripts into Vagrant Environment via SSH.
  config.vm.provision "file", source: ".vagrant/provision/scripts/format-diff", destination: "/tmp/format-diff"
  # Copy User Settings into Vagrant Environment via SSH.
  config.vm.provision "file", source: ".vagrant/provision/skel/.bash_aliases", destination: "~/.bash_aliases"
  config.vm.provision "file", source: ".vagrant/provision/skel/.bash_functions", destination: "~/.bash_functions"
  config.vm.provision "file", source: ".vagrant/provision/skel/.bash_ps1", destination: "~/.bash_ps1"
  config.vm.provision "file", source: ".vagrant/provision/skel/.gitconfig", destination: "~/.gitconfig"
  config.vm.provision "file", source: ".vagrant/provision/skel/.bashrc", destination: "/tmp/bashrc-extra"
  # Move configuration files internally using root privileges.
  config.vm.provision "shell", inline: <<-SHELL
    cat /tmp/bashrc-extra >> /home/vagrant/.bashrc
    cat /tmp/bashrc-extra >> /etc/environment
    mv /tmp/my.cnf /etc/mysql/my.cnf
    cp /tmp/php.ini /etc/php5/cli/php.ini
    mv /tmp/php.ini /etc/php5/fpm/php.ini
    mv /tmp/pma-config.php /opt/phpmyadmin/config.inc.php
    mv /tmp/xdebug.ini /etc/php5/mods-available/xdebug.ini
    mv /tmp/nginx-site.conf /etc/nginx/sites-available/default
    mv /tmp/format-diff /usr/local/bin/format-diff
    chmod +x /usr/local/bin/format-diff
    # Make sure that Composer's cache directory is owned by the right user.
    sudo -u vagrant -H mkdir -p /home/vagrant/.composer/cache
    ## Restart the services that have had configuration updates.
    service mysql restart
    service php5-fpm restart
    service nginx restart
    hostnamectl set-hostname php-vagrant-env
  SHELL
end
