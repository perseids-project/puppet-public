#Flask Github Proxy
# test at http://${vhost}/${app_path}/perseids_syriaca/
# this is an alternative version which deploys directly
# from github rather than using the pypi package
# to be removed once the fix for issue26 is released in a 
# pypi package of the fghproxy
class site::profiles::fghproxy_gh {
  $app_root = '/usr/local/fgh_gh'
  $app_path = hiera('fghproxy::app_path')

  vcsrepo { $app_root:
    ensure   => present,
    revision => hiera('fghproxy::app_revision'),
    provider => git,
    source   => hiera('fghproxy::app_repo'),
  }

  file { "${app_root}/app.wsgi":
    content           => epp('site/profiles/fghproxy/app.wsgi.epp', {
      'app_root'      => $app_root,
      'client_secret' => hiera('sosol::agents::fgh_client_secret'),
      'github_token'  => hiera('sosol::agents::fgh_github_token'),
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
    #notify       => Apache::Vhost['fgh'],
  }

  apache::vhost { 'fgh-gh':
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
