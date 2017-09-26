#Flask Github Proxy
# test at http://${vhost}/${app_path}/perseids_syriaca/
class site::profiles::fghproxy {
  $app_root = hiera('fghproxy::app_root')
  $app_path = hiera('fghproxy::app_path')

  file { $app_root:
    ensure => directory,
  }

  file { "${app_root}/requirements-py3.txt":
    require => File[$app_root],
    source  => 'puppet:///modules/site/profiles/fghproxy/requirements-py3.txt',
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/app.wsgi":
    require => File[$app_root],
    content => epp('site/profiles/fghproxy/app.wsgi.epp', {
      'app_root' => $app_root,
    }),
    notify  => Python::Virtualenv[$app_root],
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements-py3.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
    notify       => Apache::Vhost['fgh'],
  }

  apache::vhost { 'fgh':
    servername                  => hiera('fghproxy::vhost'),
    port                        => '80',
    docroot                     => $app_root,
    wsgi_daemon_process         => 'fgh',
    wsgi_daemon_process_options => {
      'python-path' => "${app_root}/venv/lib/python3.4/site-packages"
    },
    wsgi_process_group          => 'fgh',
    wsgi_script_aliases         => { $app_path => "${app_root}/app.wsgi" },
    directories                 => [
      { 'path'    => $app_root,
        'require' => 'all granted'
      }
    ],
    headers                     => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ]
  }
}
