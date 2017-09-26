# Manage Fuseki
class site::profiles::fuseki {
  include site::profiles::java6_openjdk

  $base = hiera('fuseki::base')
  $archive = hiera('fuseki::archive')

  file { "/usr/local/${base}":
    ensure => directory,
    mode   => '0755',
  }

  archive { $archive:
    path         => "/tmp/${archive}",
    source       => hiera('fuseki::archive_url'),
    extract      => true,
    extract_path => '/usr/local',
    cleanup      => true,
  }

  file { '/etc/init.d/fuseki':
    ensure  => link,
    target  => "/usr/local/${base}/fuseki",
    require => Archive[$archive],
    notify  => Service['fuseki'],
  }

  service { 'fuseki':
    ensure    => running,
    enable    => true,
    hasstatus => false,
  }

  apache::vhost { hiera('fuseki::vhost'):
    default_vhost => true,
    port          => '80',
    docroot       => '/var/www/vhost',
    proxy_pass    => hiera('fuseki::proxy_paths'),
    headers       => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS, DELETE, PUT'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
  }

  common::duplicity_job { 'fuseki_data':
    path => "usr/local/${base}/DB",
  }
}
