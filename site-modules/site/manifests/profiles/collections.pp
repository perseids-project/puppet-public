# Run the collections API
class site::profiles::collections {
  include site::profiles::python3

  $app_root = hiera('collections::app_root')
  $repos = hiera('collections::repos')

  vcsrepo { $app_root:
    ensure   => latest,
    revision => hiera('collections::release_version'),
    provider => git,
    source   => $repos,
  }

  file { "${app_root}/requirements.txt":
    source  => 'puppet:///modules/site/profiles/collections/requirements.txt',
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/production.cfg":
    content => epp('site/profiles/collections/production.cfg.epp', {
      'marmotta_url' => hiera('collections::marmotta_url'),
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
    notify       => Exec['restart-collections-gunicorn'],
  }

  python::gunicorn { 'vhost':
    ensure     => present,
    virtualenv => "${app_root}/venv",
    dir        => $app_root,
    osenv      => { 'COLLECTIONS_API_SETTINGS' => 'production.cfg' },
    timeout    => hiera('collections::gunicorn_timeout'),
    bind       => 'localhost:5000',
    appmodule  => 'run:app',
    owner      => 'www-data',
    group      => 'www-data',
  }

  exec { 'restart-collections-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['vhost'],
  }

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'collections':
    servername            => hiera('collections::vhost'),
    port                  => '80',
    docroot               => '/var/www',
    proxy_pass            => [$proxy_pass],
    headers               => $headers,
    allow_encoded_slashes => 'on',
    directories           => hiera('collections::locations'),
  }

  firewall { '100 Collections API Access':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
