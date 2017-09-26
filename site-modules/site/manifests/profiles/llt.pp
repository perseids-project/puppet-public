# Manage LLT war
class site::profiles::llt {
  require site::profiles::deployer
  include site::profiles::postgres
  include site::profiles::java6_openjdk
  include site::profiles::services::rvm
  include site::profiles::services::tomcat

  vcsrepo { '/home/deployer/llt':
    ensure   => latest,
    revision => hiera('llt::app_version'),
    user     => 'deployer',
    provider => git,
    source   => hiera('llt::app_repo'),
    require  => User['deployer'],
    notify   => Exec['install-llt'],
  }

  vcsrepo { '/home/deployer/llt-db_handler':
    ensure   => latest,
    user     => 'deployer',
    provider => git,
    source   => hiera('llt::dbhandler_repo'),
    require  => User['deployer'],
    notify   => Exec['install-llt-db'],
  }

  exec { 'install-llt-db':
    cwd         => '/home/deployer/llt-db_handler/db',
    user        => 'postgres',
    command     => 'psql -W -f create.sql',
    require     => Vcsrepo['/home/deployer/llt-db_handler'],
    refreshonly => true,
  }

  file { '/home/deployer/.pgpass':
    source => 'puppet:///modules/site/profiles/llt/prometheus.pgpass',
    owner  => 'deployer',
    mode   => '0600',
  }

  file { '/usr/local/bin/seed_llt_db.sh':
    require => Exec['install-llt-db'],
    content => epp('site/profiles/llt/seed_llt_db.sh.epp', {
      'jruby_version' => hiera('site::profiles::services::rvm::jruby_version'),
    }),
    mode    => '0755',
  }

  exec { 'seed-llt-db':
    cwd         => '/home/deployer/llt-db_handler',
    user        => 'deployer',
    command     => 'bash --login "/usr/local/bin/seed_llt_db.sh"',
    require     => File['/usr/local/bin/seed_llt_db.sh'],
    refreshonly => true,
  }

  file { '/usr/local/bin/install_llt.sh':
    content => epp('site/profiles/llt/install_llt.sh.epp', {
      'jruby_version' => hiera('site::profiles::services::rvm::jruby_version'),
      'tomcat_pwd'    => hiera('site::profiles::services::tomcat::admin_pwd'),
    }),
    mode    => '0755',
  }

  exec { 'install-llt':
    creates => '/var/lib/tomcat6/webapps/llt.war',
    cwd     => '/home/deployer/llt',
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/install_llt.sh"',
    notify  => Exec['reload-tomcat'],
    require => [File['/usr/local/bin/install_llt.sh'], Tomcat::Config::Server::Tomcat_users['tomcatadminuser'], Exec['install-llt-db']],
    timeout => '600',
  }
}
