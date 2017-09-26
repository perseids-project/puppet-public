# Manage the Sosol app
class sosol::app {

  $sosol_app_repo = hiera('sosol::app_repo')
  $build_dir = '/home/deployer/sosol'

  if $::perseids_env == 'development' {
    file { '/usr/local/gitrepos':
      ensure => directory,
      owner  => 'deployer',
    }

    file { '/usr/local/sosoldb':
      ensure => directory,
      owner  => 'deployer',
      mode   => '0777',
    }

    vcsrepo { '/usr/local/gitrepos/canonical.git':
      ensure   => bare,
      provider => git,
      owner    => 'deployer',
      source   => hiera('sosol::git_url'),
      require  => File['/usr/local/gitrepos'],
    }
    $session_domain = 'localhost'
    $dev_url = lookup('sosol::dev_url')
  } else {
    exec { 'local-db-permissions':
      command => 'echo "no local db"'
    }
    $session_domain = '.perseids.org'
    $dev_url = ''
  }

  if $::perseids_env in ['production', 'staging'] {
    file { '/usr/local/gitrepos':
      ensure => link,
      target => '/mnt/data/gitrepo/data',
    }
  }

  exec { 'checkout-sosol':
    cwd     => '/home/deployer',
    command => "/usr/bin/git clone ${sosol_app_repo} sosol",
    user    => 'deployer',
    creates => $build_dir,
    notify  => Vcsrepo[$build_dir],
  }

  exec { 'reset-sosol':
    cwd         => $build_dir,
    command     => '/usr/bin/git reset --hard',
    user        => 'deployer',
    refreshonly => true,
  }

  vcsrepo { $build_dir:
    ensure   => latest,
    user     => 'deployer',
    provider => 'git',
    source   => $sosol_app_repo,
    revision => hiera('sosol::release_version'),
    notify   => Exec['install-sosol'],
    require  => [Class['site::profiles::deployer'],Exec['reset-sosol']]
  }

  file { "${build_dir}/config/agents.yml":
    content => epp('sosol/agents.yml.epp',
      {
        'eagle_password'    => hiera('sosol::agents::eagle_password'),
        'eagle_api_url'     => hiera('sosol::agents::eagle_api_url'),
        'fgh_client_secret' => hiera('sosol::agents::fgh_client_secret'),
        'fgh_proxy_url'     => hiera('sosol::agents::fgh_proxy_url'),
        'srophe_api_key'    => hiera('sosol::agents::srophe_api_key'),
        'srophe_api_url'    => hiera('sosol::agents::srophe_api_url'),
        'cts_api_url'       => hiera('sosol::agents::cts_api_url'),
      }),
    owner   => 'deployer',
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
  }

  file { "${build_dir}/config/cite.yml":
    content => epp('sosol/cite.yml.epp', {}),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/board_mailers.yml":
    content => epp('sosol/board_mailers.yml.epp', {}),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/collections.yml":
    content => epp('sosol/collections.yml.epp',
      {
        'collections_api_url' => hiera('collections::vhost'),
      }),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/cts.yml":
    content => epp('sosol/cts.yml.epp'),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/database.yml":
    content => epp('sosol/database.yml.epp',
      {
        'db_user'       => hiera('sosol::db::user'),
        'db_password'   => hiera('sosol::db::password'),
        'db_endpoint'   => hiera('sosol::db::endpoint'),
        'db_local_path' => '/usr/local/sosoldb',
      }),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }


  file { "${build_dir}/config/shibboleth.yml":
    content => epp('sosol/shibboleth.yml.epp'),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/tools.yml":
    content => epp('sosol/tools.yml.epp',
      {
        'cite_mapper_url'       => hiera('sosol::tools::cite_mapper_url'),
        'tokenizer_service_url' => hiera('sosol::tools::tokenizer_service_url'),
        'arethusa_url'          => hiera('sosol::tools::arethusa_url'),
        'alpheios_url'          => hiera('sosol::tools::alpheios_url'),
        'review_service_url'    => hiera('sosol::tools::review_service_url'),
        'pca_url'               => hiera('sosol::tools::pca_url'),
        'oa_editor_url'         => hiera('sosol::tools::oa_editor_url'),
      }),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/environments/${::perseids_env}.rb":
    content => epp("sosol/environments/${::perseids_env}.rb.epp",
      {
        'smtp_user'     => hiera('sosol::smtp_user'),
        'smtp_password' => hiera('sosol::smtp_password'),
        'dev_url'       => $dev_url,
      }),
    require => Vcsrepo[$build_dir],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/environments/${::perseids_env}_secret.rb":
    content => epp("sosol/environments/${::perseids_env}_secret.rb.epp",
      {
        'rpx_api_key' => hiera('sosol::rpx_api_key'),
      }),
    require => Vcsrepo['/home/deployer/sosol'],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/initializers/airbrake.rb":
    content => epp('sosol/initializers/airbrake.rb.epp',
      {
        'airbrake_api_key' => hiera('sosol::airbrake_api_key'),
      }),
    require => Vcsrepo['/home/deployer/sosol'],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/initializers/session_store.rb":
    content => epp('sosol/initializers/session_store.rb.epp',
      {
        'session_secret' => hiera('sosol::session_secret'),
        'session_domain' => $session_domain,
      }),
    require => Vcsrepo['/home/deployer/sosol'],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/initializers/site.rb":
    content => epp('sosol/initializers/site.rb.epp',
      { 'cookie_domain' => $session_domain,
      }),
    require => Vcsrepo['/home/deployer/sosol'],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { "${build_dir}/config/initializers/site.terms.erb":
    content => epp('sosol/initializers/site.terms.erb.epp'),
    require => Vcsrepo['/home/deployer/sosol'],
    notify  => Exec['install-sosol'],
    owner   => 'deployer',
  }

  file { '/usr/local/bin/install_sosol.sh':
    content => epp('sosol/install_sosol.sh.epp',
      {
        'jruby_version' => hiera('sosol::jruby_version'),
        'rails_env'     => hiera('sosol::rails_env'),
        'tomcat_pwd'    => hiera('sosol::tomcat::admin_pwd'),
      }),
    mode    => '0755',
  }

  file { '/usr/local/bin/install_sosol_local.sh':
    content => epp('sosol/install_sosol_local.sh.epp',
      {
        'jruby_version' => hiera('sosol::jruby_version'),
        'rails_env'     => hiera('sosol::rails_env'),
      }),
    mode    => '0755',
  }

  if $::perseids_env == 'development' {
    exec { 'install-sosol':
      cwd         => '/home/deployer/sosol',
      user        => 'deployer',
      command     => 'bash --login "/usr/local/bin/install_sosol_local.sh"',
      refreshonly => true,
      timeout     => 0,
    }
  } else {
    exec { 'install-sosol':
      cwd         => '/home/deployer/sosol',
      user        => 'deployer',
      command     => 'bash --login "/usr/local/bin/install_sosol.sh"',
      refreshonly => true,
      notify      => Exec['reload-tomcat'],
      require     => Tomcat::Config::Server::Tomcat_users['tomcatadminuser'],
      timeout     => 600,
    }
  }

  # this is a ridiculous hack for code that pulls in the iframe template
  # in the sosol epi_cts_identifier preview display from the root dir
  # code really should be fixed but until then we need this link
  file { '/var/www/templates':
    ensure  => link,
    target  => '/var/lib/tomcat6/webapps/sosol/templates',
    require => Exec['install-sosol'],
  }
}
