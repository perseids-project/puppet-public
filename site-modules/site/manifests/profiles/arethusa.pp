# Run the Arethusa app
class site::profiles::arethusa {
  require site::profiles::deployer
  include apache
  include site::profiles::arethusa::rvm
  include site::profiles::node::ten
  include site::profiles::arethusa::client

  $ruby_version = hiera('arethusa::ruby_version')
  $node_version = hiera('arethusa::node_version')
  $app_root = hiera('arethusa::app_root')
  $deploy_root = hiera('arethusa::deploy_root')


  vcsrepo { $app_root:
    revision => hiera('arethusa::app_version'),
    user     => 'deployer',
    provider => git,
    source   => hiera('arethusa::app_repo'),
    require  => User['deployer'],
    notify   => Exec['build-arethusa'],
  }

  exec { 'install-sass':
    cwd     => $app_root,
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem install sass -v 3.3.14",
    require => [Vcsrepo[$app_root], User['deployer'], Rvm_system_ruby["ruby-${ruby_version}"]],
    unless  => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem spec sass",
    notify  => Exec['build-arethusa'],
  }

  file { '/usr/local/bin/build-arethusa':
    content => epp('site/profiles/arethusa/build-arethusa.sh.epp',
    {
      'ruby_version' => $ruby_version,
      'node_version' => $node_version, }),
    mode    => '0775',
  }

  exec { 'build-arethusa':
    cwd     => $app_root,
    environment => ["HOME=/home/deployer", "NVM_DIR=/home/deployer/.nvm"],
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/build-arethusa"',
    require => [Exec['install-arethusa-client'],File['/usr/local/bin/build-arethusa']],
    creates => "${app_root}/bower_components",
    notify  => Exec['deploy-arethusa'],
    timeout     => 0,
  }

  file { '/usr/local/bin/deploy-arethusa':
    source => 'puppet:///modules/site/profiles/arethusa/deploy-arethusa.sh',
    mode   => '0775',
  }

  exec { 'deploy-arethusa':
    cwd         => $app_root,
    command     => "/usr/local/bin/deploy-arethusa ${deploy_root}",
    require     => File['/usr/local/bin/deploy-arethusa'],
    refreshonly => true,
  }

  apache::vhost { hiera('arethusa::vhost'):
    port    => '80',
    docroot => $deploy_root,
  }

  firewall { '100 Allow web traffic for Arethusa':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
