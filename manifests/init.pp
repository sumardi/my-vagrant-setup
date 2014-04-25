# Default path
Exec { path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin', '/usr/local/sbin', '/opt/local/bin'] }
exec { 'yum update':
  command => 'yum -y update'
}

# Edit local /etc/hosts files to resolve some hostnames used on your application.
host { 'localhost.localdomain':
    ensure => 'present',
    target => '/etc/hosts',
    ip => '127.0.0.1',
    host_aliases => ['localhost','memcached','mysql','redis']
}

# Epel Repo
class { 'epel': }

# Memcached server (12MB)
class { "memcached":
  port => '11211',
  maxconn => '2048',
  cachesize => '12'
}

# Firewall
class iptables {
	package { "iptables":
		ensure => present
	}

	service { "iptables":
		require => Package["iptables"],
		hasstatus => true,
		status => "true",
		hasrestart => false,
	}

	file { "/etc/sysconfig/iptables":
		owner   => "root",
		group   => "root",
		mode    => 600,
		replace => true,
		ensure  => present,
		source  => "/vagrant/files/iptables.txt",
		require => Package["iptables"],
		notify  => Service["iptables"],
	}
}
class { 'iptables': }

# MySQL
class { '::mysql::server':
  root_password 	=> $password,
  override_options => {
    'mysqld' => {
      'max_connections' => '1024'
    }
  }
}
mysql::db { $db_name:
  user     => $username,
  password => $password,
  host     => $host,
  grant    => ['ALL'],
}

# Nginx
include nginx
nginx::file { 'www.conf':
  content => template('/vagrant/files/www.conf.erb'),
}
nginx::file { 'php.conf.inc':
  source => 'puppet:///modules/nginx/php.conf.inc',
}

# PHP
php::ini {
	'/etc/php.ini':
        display_errors	=> 'On',
        short_open_tag	=> 'Off',
        memory_limit	=> '256M',
        date_timezone	=> 'Asia/Kuala_Lumpur'
}

include php::cli
include php::fpm::daemon
php::fpm::conf { 'www':
    listen  => '127.0.0.1:9001',
    user    => 'vagrant',
    # For the user to exist
    require => Package['nginx'],
}

php::module { [ 'devel', 'pear', 'mysql', 'mbstring', 'pear-Net-Curl', 'imap', 'pecl-xdebug', 'xml', 'gd', 'tidy', 'pecl-apc', 'pecl-memcache', 'pecl-imagick', 'mcrypt', 'pdo']: }

# Redis
class redis {
    package { "redis":
        ensure => 'latest',
	require => Yumrepo['epel'],
    }
    service { "redis":
        enable => true,
        ensure => running,
    }
}
include redis

# PHPUnit
exec { '/usr/bin/pear upgrade pear':
    require => Package['php-pear'],
    timeout => 0
}

define discoverPearChannel {
    exec { "/usr/bin/pear channel-discover $name":
        onlyif => "/usr/bin/pear channel-info $name | grep \"Unknown channel\"",
        require => Exec['/usr/bin/pear upgrade pear'],
        timeout => 0
    }
}
discoverPearChannel { 'pear.phpunit.de': }
discoverPearChannel { 'components.ez.no': }
discoverPearChannel { 'pear.symfony-project.com': }
discoverPearChannel { 'pear.symfony.com': }

exec { '/usr/bin/pear install --alldeps pear.phpunit.de/PHPUnit':
    onlyif => "/usr/bin/pear info phpunit/PHPUnit | grep \"No information found\"",
    require => [
        Exec['/usr/bin/pear upgrade pear'],
        DiscoverPearChannel['pear.phpunit.de'],
        DiscoverPearChannel['components.ez.no'],
        DiscoverPearChannel['pear.symfony-project.com'],
        DiscoverPearChannel['pear.symfony.com']
    ],
    user => 'root',
    timeout => 0
}

# NodeJS
include nodejs
package { 'grunt-cli':
  ensure   => present,
  provider => 'npm',
}
package { 'gulp':
  ensure   => present,
  provider => 'npm',
}

# Git
include git
git::config { 'user.name':
  value => $git_user,
}
git::config { 'user.email':
  value => $git_email,
}

# Composer
include composer
composer::exec { 'laravel-update':
    cmd                  => 'update',  # REQUIRED
    cwd                  => '/vagrant/www', # REQUIRED
    packages             => [], # leave empty or omit to update whole project
    prefer_source        => false, # Only one of prefer_source or prefer_dist can be true
    prefer_dist          => false, # Only one of prefer_source or prefer_dist can be true
    dry_run              => false, # Just simulate actions
    custom_installers    => false, # No custom installers
    scripts              => false, # No script execution
    interaction          => false, # No interactive questions
    optimize             => false, # Optimize autoloader
    dev                  => false, # Install dev dependencies
    user                 => undef, # Set the user to run as
    refreshonly          => false, # Only run on refresh
}

# Beanstalkd
include beanstalkd
