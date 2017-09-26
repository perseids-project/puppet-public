# Frontend and local tools for Sosol app
class sosoldev::web {
  include site::profiles::apache
  include sosoldev::ssl

  $sosol_app_url = 'localhost'
  $ae_git_url = hiera('sosol::annotation_editor::git_url')
  $ae_release = hiera('sosol::annotation_editor::release_version')
  $pca_path = hiera('pca::app_path')

  apache::vhost { $sosol_app_url:
    default_vhost   => true,
    port            => '8080',
    docroot         => '/var/www',
    options         => ['-Indexes', 'FollowSymLinks'],
    setenvif        => ['Origin "^(.*\.perseids\.org)$" ORIGIN_SUB_DOMAIN=$1'],
    headers         => [
      'set Access-Control-Allow-Origin: "%{ORIGIN_SUB_DOMAIN}e" env=ORIGIN_SUB_DOMAIN',
      'always set Access-Control-Allow-Methods "POST, GET, OPTIONS"',
      'set Access-Control-Allow-Headers: "Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token, Authorization"',
      'set Access-Control-Allow-Credentials: true'],
    error_documents => hiera('sosol::error_documents'),
    proxy_pass      => hiera('sosoldev::proxy_paths'),
    wsgi_daemon_process         => 'pca',
    wsgi_daemon_process_options => {
      'python-path'             => "${pca_path}/venv/lib/python3.4/site-packages"
    },
    wsgi_process_group          => 'pca',
    wsgi_script_aliases         => {
      '/apps' => "${pca_path}/app.wsgi"
    },
    directories                 => [
      { 'path'    => $pca_path,
        'require' => 'all granted'
      }
    ],
  }


  file {'/var/www/index.html':
    content => template('sosol/index.html.erb'),
    mode    => '0666',
    require => Apache::Vhost[$sosol_app_url],
  }

  file {'/var/www/503.html':
    content => template('sosol/503.html.erb'),
    mode    => '0666',
    require => Apache::Vhost[$sosol_app_url],
  }


  file { '/var/www/tools':
    ensure  => directory,
    owner   => 'deployer',
    group   => 'deployer',
    require => Class['site::profiles::deployer'],
  }

  vcsrepo { '/var/www/tools/annotation-editor':
    ensure   => latest,
    user     => 'deployer',
    provider => git,
    source   => $ae_git_url,
    revision => $ae_release,
    require  => File['/var/www/tools'],
  }
}
