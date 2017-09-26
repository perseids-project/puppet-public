# Be the Morphology server
class site::profiles::morphology {
  include morpheus
  include site::profiles::python3
  class { 'redis': 
    maxmemory        => hiera('morphology::redis::maxmemory'),
    maxmemory_policy => 'allkeys-lru',
  }

  $app_root = hiera('morphology::app_root')
  $repos = hiera('morphology::repos')
  $redis_host = hiera('morphology::redis_host')

  vcsrepo { $app_root:
    ensure   => latest,
    revision => hiera('morphology::release_version'),
    provider => git,
    source   => $repos,
  }

  file { "${app_root}/requirements.txt":
    ensure  => file,
    source  => 'puppet:///modules/site/profiles/morphology/requirements.txt',
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/morphsvc/production.cfg":
    ensure  => file,
    content => epp('site/profiles/morphology/production.cfg.epp', {
      'morpheus_path'         => hiera('morpheus::binary_path'),
      'morpheus_stemlib_path' => hiera('morpheus::stemlib_dir'),
      'aramorph_url'          => hiera('morphology::aramorph_url'),
      'whitakers_url'         => hiera('morphology::whitakers_url'),
      'lex_grc_url'           => hiera('morphology::lex_grc_url'),
      'lex_lat_url'           => hiera('morphology::lex_lat_url'),
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/app.py":
    ensure  => file,
    content => epp('site/profiles/morphology/app.py.epp', {
      'redis_host'  => hiera('morphology::redis_host'),
      'redis_port'  => hiera('morphology::redis_port'),
      'config_file' => 'production.cfg',
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
    notify       => Exec['restart-morph-gunicorn'],
  }

  python::gunicorn { 'morphology-vhost':
    ensure     => present,
    virtualenv => "${app_root}/venv",
    dir        => $app_root,
    timeout    => hiera('morphology::gunicorn_timeout'),
    bind       => 'localhost:5000',
    appmodule  => 'app:app',
    owner      => 'www-data',
    group      => 'www-data',
  }

  exec { 'restart-morph-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['morphology-vhost'],
  }

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'morphology':
    servername => hiera('morphology::vhost'),
    port       => '80',
    docroot    => '/var/www/vhost',
    proxy_pass => [$proxy_pass],
    headers    => $headers,
  }

  file { '/etc/ssl/certs/__perseids_org_cert.pem':
    content => lookup('site::ssl::cert_pem'),
  }

  file { '/etc/ssl/certs/__perseids_org_interm.cer':
    content => lookup('site::ssl::interm_cer'),
  }

  file { '/etc/ssl/private/__perseids_org.key':
    content => lookup('site::ssl::key'),
    mode   => '0640',
  }

  apache::vhost { 'morphology-ssl':
    servername => hiera('morphology::vhost'),
    port        => '443',
    docroot     => '/var/www/vhost',
    proxy_pass => [$proxy_pass],
    headers    => $headers,
    ssl         => true,
    ssl_cert    => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key     => '/etc/ssl/private/__perseids_org.key',
    ssl_chain   => '/etc/ssl/certs/__perseids_org_interm.cer',
  }

  firewall { '100 Morphology Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

}
