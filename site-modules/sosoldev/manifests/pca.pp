# Deploy the Perseids Client Applications
class sosoldev::pca {
  include site::profiles::python3
  include site::profiles::node::ten

  $app_path = hiera('pca::app_path')
  $sosol_url = 'http://localhost:3000'
  $llt_url = hiera('pca::llt_url')
  $cts_url = hiera('pca::cts_url')

  file { $app_path:
    ensure  => directory,
    owner   => 'deployer',
    require => User['deployer'],
  }

  vcsrepo { $app_path:
    ensure   => latest,
    revision => hiera('pca::app_release'),
    provider => git,
    user     => 'deployer',
    require  => File[$app_path],
    source   => hiera('pca::source_repo'),
  }

  file { "${app_path}/app.wsgi":
    content => epp('site/profiles/pca/app.wsgi.epp', {
      'app_path' => $app_path,
    }),
    require => Vcsrepo[$app_path],
    notify  => Python::VirtualEnv[$app_path],
    owner   => 'deployer',
    group   => 'deployer',
  }

  file { "${app_path}/app/configurations/alignment.py":
    content          => epp('site/profiles/pca/alignment.py.epp', {
      'sosol_url'    => $sosol_url,
      'llt_url'      => $llt_url,
      'editor_url'    => 'http://localhost:8080/alpheios/app/align-editsentence-perseids-test.xhtml?doc=REPLACE_DOC&s=1',
      'cts_url'      => $cts_url,
    }),
    require => Vcsrepo[$app_path],
    notify  => Python::VirtualEnv[$app_path],
    owner   => 'deployer',
    group   => 'deployer',
  }

  file { "${app_path}/app/configurations/treebank.py":
    content => epp('site/profiles/pca/treebank.py.epp', {
      'sosol_url'  => $sosol_url,
      'llt_url'    => $llt_url,
      'editor_url' => 'http://localhost:8080/tools/arethusa/app/#/perseids_local',
      'cts_url'    => $cts_url,
    }),
    require => Vcsrepo[$app_path],
    notify  => Python::VirtualEnv[$app_path],
    owner   => 'deployer',
    group   => 'deployer',
  }

  file { "${app_path}/app/configurations/cts.py":
    content => epp('site/profiles/pca/cts.py.epp', {
      'cts_url'      => $cts_url,
    }),
    require => Vcsrepo[$app_path],
    notify  => Python::VirtualEnv[$app_path],
    owner   => 'deployer',
    group   => 'deployer',
  }

  file { "${app_path}/app/configurations/session.py":
    content => epp('site/profiles/pca/session.py.epp', {
      'sosol_url' => $sosol_url,
    }),
    require => Vcsrepo[$app_path],
    notify  => Python::VirtualEnv[$app_path],
    owner   => 'deployer',
    group   => 'deployer',
  }

  file { '/usr/local/bin/build-pca-js':
    content => epp('site/profiles/pca/build-pca-js.sh.epp',
    {
      'node_version' => hiera('pca::node_version')}),
    mode    => '0775',
  }

  exec { 'pca-bower':
    user    => 'deployer',
    cwd     => "${app_path}/app",
    command => 'bash --login "/usr/local/bin/build-pca-js"',
    require => [File['/usr/local/bin/build-pca-js'],Vcsrepo[$app_path]],
    creates => "${app_path}/app/bower_components"
  }

  python::virtualenv { $app_path:
    ensure       => present,
    version      => '3',
    requirements => "${app_path}/requirements.txt",
    venv_dir     => "${app_path}/venv",
    cwd          => $app_path,
    notify       => Class['apache::service'],
  }

}
