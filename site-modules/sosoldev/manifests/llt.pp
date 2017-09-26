# Manage LLT war
class sosoldev::llt {
  require site::profiles::deployer
  include site::profiles::postgres

  $jruby_version = hiera('sosol::jruby_version')

  vcsrepo { '/home/deployer/llt':
    ensure   => latest,
    revision => 'master',
    user     => 'deployer',
    provider => git,
    source   => hiera('llt::app_repo'),
    require  => User['deployer'],
    notify  => Exec['install-llt-local'],
  }

  vcsrepo { '/home/deployer/llt-db_handler':
    ensure   => latest,
    user     => 'deployer',
    provider => git,
    source   => hiera('llt::dbhandler_repo'),
    require  => User['deployer'],
    notify   => Exec['install-llt-db'],
  }

  file { '/home/deployer/.pgpass':
    source => 'puppet:///modules/site/profiles/llt/prometheus.pgpass',
    owner  => 'deployer',
    mode   => '0600',
  }

  file { '/tmp/llt-db-create.sql':
    source  => '/home/deployer/llt-db_handler/db/create.sql',
    require => Vcsrepo['/home/deployer/llt-db_handler'],
  }

  exec { 'install-llt-db':
    user        => 'postgres',
    command     => 'psql -W -f /tmp/llt-db-create.sql',
    refreshonly => true,
    require     => [File['/home/deployer/.pgpass'],File['/tmp/llt-db-create.sql']],
  }

  file { '/usr/local/bin/seed_llt_db.sh':
    require => Exec['install-llt-db'],
    content => epp('site/profiles/llt/seed_llt_db.sh.epp', {
      'jruby_version' => $jruby_version,
    }),
    mode    => '0755',
  }

  exec { 'seed-llt-db':
    cwd         => '/home/deployer/llt-db_handler',
    user        => 'deployer',
    command     => 'bash --login "/usr/local/bin/seed_llt_db.sh"',
    require     => [File['/usr/local/bin/seed_llt_db.sh'],Exec['install-llt-db']],
    refreshonly => true,
  }

  file { '/usr/local/bin/install_llt_local.sh':
    content => epp('site/profiles/llt/install_llt_local.sh.epp', {
      'jruby_version' => $jruby_version,
    }),
    mode    => '0755',
    notify   => Exec['install-llt-local'],
  }

  exec { 'install-llt-local':
    environment  => ["HOME=/home/deployer"],
    cwd          => '/home/deployer/llt',
    user         => 'deployer',
    command      => 'bash --login "/usr/local/bin/install_llt_local.sh"',
    require      => [File['/usr/local/bin/install_llt_local.sh'],Exec['seed-llt-db']],
    refreshonly  => true,
  }

}
