# Vagrant
My vagrant setup for Laravel development.

## Requirements
* [Virtualbox 4.3.x](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant 1.5.x](https://www.vagrantup.com/downloads.html)

## Setup

First, clone this repository.
```
git clone https://github.com/sumardi/vagrant.git vagrant
cd vagrant
```
Then, update submodule.
```
git submodule update --init --recursive
```
Fire up vagrant.
```
vagrant up --provision
```
The first time you run vagrant it will need to fetch the virtual box image which is ~450mb so depending on your download speed this could take some time. Grab a cup of `0xC00FEE`!

After the provisioning has completed, you can access your project at http://192.168.13.37 in a browser.

## Installed Software

* Centos 6.5 (64bit)
* Nginx 1.6.0
* MySQL 5.1.73
* PHP 5.3.3 (with mbstring, mysql, curl, gd, dom, mcrypt, imap, xdebug, pdo, pear)
* Composer
* PHPUnit 4.0.17
* Beanstalkd 1.9
* NodeJS 0.10.26 (with Grunt, Gulp)
* Redis 2.4.10
* Memcached
* Git 1.7.1

## Default Credentials
### MySQL
* User : root / laravel
* Password : 1234
* Port Forwarded : `3306` => `1337`
* Database : ldev

### Nginx
* ServerName : localhost.localdomain
* Port Forwarded : `80` => `8000`

### Beanstalkd
* Port : `11300`
