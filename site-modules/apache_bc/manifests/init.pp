# Manage Apache webserver
class apache_bc {
  $apache_pkg = hiera('apache_pkg')
  $apache_service = hiera('apache_service')
  $apache_path = hiera('apache_path')

  package { $apache_pkg: ensure => installed }

  file { "${apache_path}/apache2.conf":
    source  => 'puppet:///modules/apache_bc/apache2.conf',
    require => Package[$apache_pkg],
    notify  => Service[$apache_service],
  }

  service { $apache_service:
    ensure  => running,
    enable  => true,
    require => Package[$apache_pkg],
  }

  exec { 'reload-apache':
    command     => '/sbin/service httpd reload',
    refreshonly => true,
  }

  file { "${apache_path}/conf.d/welcome.conf":
    ensure  => absent,
    require => Package[$apache_pkg],
  }
}
