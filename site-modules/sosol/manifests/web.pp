# Frontend and local tools for Sosol app
class sosol::web {
  include apache
  include sosol::ssl

  $sosol_app_url = hiera('sosol::app_url')
  $ae_git_url = hiera('sosol::annotation_editor::git_url')
  $ae_release = hiera('sosol::annotation_editor::release_version')

  apache::vhost { $sosol_app_url:
    default_vhost   => true,
    port            => '80',
    docroot         => '/var/www',
    options         => ['-Indexes'],
    setenvif        => ['Origin "^(.*\.perseids\.org)$" ORIGIN_SUB_DOMAIN=$1'],
    headers         => [
      'set Access-Control-Allow-Origin: "%{ORIGIN_SUB_DOMAIN}e" env=ORIGIN_SUB_DOMAIN',
      'always set Access-Control-Allow-Methods "POST, GET, OPTIONS"',
      'set Access-Control-Allow-Headers: "Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token, Authorization"',
      'set Access-Control-Allow-Credentials: true'],
    error_documents => hiera('sosol::error_documents'),
    proxy_pass      => hiera('sosol::proxy_paths'),
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
