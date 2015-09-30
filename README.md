# PHP Vagrant Environment

This project is designed to provide a development environment for PHP web applications, without having to
install PHP (and Nginx/Apache) on your computer. It is meant to be as similar to a server as possible.

It includes: [Nginx](http://nginx.org), [PHP](http://php.net) 5.6 (with a sensible selection of extensions
including [XDebug](http://xdebug.org) for debugging), [MySQL](https://www.mysql.com), [Redis](http://redis.io),
[NodeJS](https://nodejs.org/en/), [Java](http://openjdk.java.net/), [Git](http://git-scm.com), and
[Docker](https://www.docker.com).

> A basic project called `info` is included with this project. It will be used for the examples in this README.

## Conventions

Throughout this README, the symbols `>` and `$` are used to indicate where you should execute commands.
- `>` indicates you should run the command on the *host* machine (your computer).
- `$` indicates you should run the command on the *guest* machine (inside the Vagrant environment).

## Installation

- Install [Virtualbox](https://www.virtualbox.org) and [Vagrant](https://www.vagrantup.com).
- Grab a copy of this project.
  - Download the [latest release](https://github.com/zanderbaldwin/vagrant-env/releases/latest).
  - If you have [Git](http://git-scm.com) installed, you may clone this repository from [`git://github.com/zanderbaldwin/vagrant-env.git`](https://github.com/zanderbaldwin/vagrant-env).
- Extract to your `$HOME` directory.
- Run the following commands:
  - `> cd $HOME`
  - `> vagrant up`
- Celebrate! ... Eventually, after it has downloaded and set everything up.

Once you have set up the PHP Vagrant environment once, you shouldn't have to go through this lengthy process
again unless you destroy the environment.

#### Starting the Vagrant Environment

Each time you turn off your computer, the Vagrant environment will stop. To start it again after turning
on your computer, run the following commands:

```bash
> cd $HOME
> vagrant up
```

## Domain Mapping

This project works by mapping `.vagrant` domains to the server software inside the Vagrant environment. Domains
need to be mapped to the IP address of the Vagrant machine (which is `192.168.84.78`).

Using the `info` example project, its domain would be [`info.vagrant`](http://info.vagrant).

#### Unix / Linux

- Install DNSMasq through your package manager (eg. `sudo apt-get install dnsmasq`).
- Create the file `/etc/dnsmasq.d/vagranttld.conf` with the following contents:

```
vagrant=/vagrant/
address=/vagrant/192.168.84.78
```

- Restart DNSMasq (eg. `sudo service dnsmasq restart`).

#### Windows

Sorry, you're out of luck.

You'll have to add an entry in `C:\Windows\System32\drivers\etc\hosts` for every domain you want to map.

```
127.0.0.1       localhost

# Start mapping your domains here...
192.168.84.78   info.vagrant
```

## Folder Structure

Each project is a folder inside the `$HOME/code` folder. So for the project called `info`, the Vagrant
environment will look for a folder called `$HOME/code/info`.

This folder will contain your project, but the server software inside the Vagrant machine will actually look
for website files inside the `web` subdirectory (called the *webroot*). Following the example above, this
would be `$HOME/code/info/web`.

The server software will look for certain files (listed below, in order) to run, otherwise it will show the contents of the folder.

- `dev.php`
- `app_dev.php`
- `app.php`
- `index.php`
- `index.html`
- `index.htm`

## Server Access

The Vagrant environment is pretty much a server. To run commands you need to log into the Vagrant environment first via SSH.

```bash
> cd $HOME
> vagrant ssh
```

## Database Details

Your apps should use the following database credentials:

| Credential | Value         |
| ---------- | ------------- |
| Host       | `localhost`   |
| User       | `root`        |
| Password   | *No password* |

To create a new database, use the MySQL command-line tool.

```bash
> cd $HOME
> vagrant ssh
$ mysql -u root
mysql> CREATE DATABASE `name-of-your-database`;
```

## Destroying the Environment

The Vagrant environment is a great way to play around with a Linux server. Do anything you want.

If cause a problem you can't fix, or break the server entirely, then simply destroy the environment and create a new one!

```bash
> cd $HOME
> vagrant destroy
> vagrant up
```

You'll have to download and setup the Vagrant environment again, but at least you won't have to re-install
your operating system!

Which is what I used to do. Before I knew virtualisation existed.
