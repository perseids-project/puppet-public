# Manage the Sosol exist db
class sosol::exist {
  include sosol::alpheios
  include sosol::cts

  class { 'docker':
    dns => hiera('docker::dns'),
  }

  file { '/usr/local/docker-existdb':
    ensure => directory,
  }

  file { '/usr/local/docker-existdb/Dockerfile':
    content => template('sosol/Dockerfile.erb'),
    notify  => Docker::Image['existdb'],
  }

  file { '/usr/local/docker-existdb/exist-setup.cmd':
    content => template('sosol/exist-setup.cmd.erb'),
    mode    => '0755',
    notify  => Docker::Image['existdb'],
  }

  file { '/usr/local/docker-existdb/exist-startup.sh':
    content => template('sosol/exist-startup.sh.erb'),
    mode    => '0755',
    notify  => Docker::Image['existdb'],
  }

  file { '/usr/local/docker-existdb/start-all.sh':
    content => template('sosol/start-all.sh.erb'),
    mode    => '0755',
  }

  docker::image { 'existdb':
    docker_dir => '/usr/local/docker-existdb',
  }

  docker::run { 'sosol-exist':
    image   => 'existdb',
    ports   => '8800:8080',
    require => Docker::Image['existdb'],
  }

  $exist_acl = hiera('exist_acl')

  $exist_acl.each |String $source_ip| {
    firewall { "100 Exist access from ${source_ip}":
      proto  => 'tcp',
      dport  => '8800',
      source => $source_ip,
      action => 'accept',
    }
  }
}
