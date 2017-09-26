# Be the WWW server
class site::profiles::www {
  include site::profiles::apache
  require site::profiles::deployer

  $docroot = hiera('site::profiles::www::docroot')

  file { $docroot:
    ensure  => directory,
    owner   => 'deployer',
    require => User['deployer'],
  }

  vcsrepo { $docroot:
    ensure   => latest,
    revision => 'master',
    provider => git,
    user     => 'deployer',
    require  => File[$docroot],
    source   => hiera('site::profiles::www::repo'),
  }

  apache::vhost { hiera('site::profiles::www::vhost'):
    port          => '80',
    serveraliases => [ 'perseids.org'],
    docroot       => $docroot,
    proxy_pass    => hiera('site::profiles::www::proxy_paths'),
    rewrites      => hiera('site::profiles::www::rewrites'),
    headers       => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS, DELETE, PUT'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
  }

  apache::vhost { 'www-ssl':
    servername  => hiera('site::profiles::www::vhost'),
    port        => '443',
    docroot     => $docroot,
    proxy_pass    => hiera('site::profiles::www::proxy_paths'),
    rewrites      => hiera('site::profiles::www::rewrites'),
    headers       => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS, DELETE, PUT'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
    ssl         => true,
    ssl_cert    => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key     => '/etc/ssl/private/__perseids_org.key',
    ssl_chain   => '/etc/ssl/certs/__perseids_org_interm.cer',
  }

  firewall { '100 Allow web traffic for www':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

}
