# Deploy the Journey of the Hero Prototype
class site::profiles::joth {
  require site::profiles::deployer
  include site::profiles::python3

  $deploy_path = hiera('joth::deploy_path')
  $vhost = hiera('joth::vhost')
  $pca_path = hiera('joth::pca_path')

  vcsrepo { $deploy_path:
    ensure   => present,
    revision => hiera('joth::source_version'),
    provider => git,
    source   => hiera('joth::source_repo'),
  }

  file { "${deploy_path}/perseids-client-apps/app.wsgi":
    content => epp('site/profiles/joth/app.wsgi.epp', {
      'app_path' => "${deploy_path}/perseids-client-apps",
    }),
    require => Vcsrepo[$deploy_path],
  }

  file { "${deploy_path}/gapvis/config/settings.dev.js":
    content => epp('site/profiles/joth/settings.dev.js.epp', {
      'pca_vhost' => "http://${vhost}/${pca_path}",
      'cts_api'   => hiera('joth::cts_api'),
    }),
    require => Vcsrepo[$deploy_path],
  }

  archive { "${deploy_path}/data/data.tgz":
    source       => "${deploy_path}/data/data/tgz",
    extract      => true,
    extract_path => "${deploy_path}/data",
    cleanup      => false,
    creates      => "${deploy_path}/data/joth",
    require      => Vcsrepo[$deploy_path],
  }

  file { "${deploy_path}/perseids-client-apps/joth/data":
    ensure => link,
    target => "${deploy_path}/data/joth",
  }

  file { "${deploy_path}/perseids-client-apps/joth/pleiades":
    ensure => link,
    target => "${deploy_path}/data/pleiades-geojson/geojson",
  }

  apache::vhost { $vhost:
    servername                  => $vhost,
    port                        => '80',
    docroot                     => "${deploy_path}/gapvis",
    wsgi_daemon_process         => 'joth',
    wsgi_daemon_process_options => {
      'python-path' => "${deploy_path}/perseids-client-apps/venv/lib/python3.4/site-packages"
    },
    wsgi_process_group          => 'joth',
    wsgi_script_aliases         => {
      "/${pca_path}" => "${deploy_path}/perseids-client-apps/app.wsgi"
    },
    directories                 => [
      { 'path'    => $deploy_path,
        'require' => 'all granted'
      }
    ],
    headers                     => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
  }



}
