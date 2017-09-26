# perseids prototype publications
class site::profiles::pubs {
  include apache
  require site::profiles::deployer

  $vhost = hiera('pubs::vhost')
  $docroot = hiera('pubs::docroot')
  $apps = hiera_hash('pubs::vcsapps')

  file { $docroot:
    ensure  => directory,
    owner   => 'deployer',
    require => User['deployer'],
  }

  $apps.each | String $app_name, Hash $params | {
    vcsrepo { "${docroot}/${app_name}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      user     => 'deployer',
      require  => File[$docroot],
      *        => $params,
    }
  }

  apache::vhost { $vhost:
    servername => $vhost,
    port       => '80',
    docroot    => $docroot,
  }

  firewall { '100 Allow web traffic for pubs':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

}
