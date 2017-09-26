# Manage Arethusa Configs
class site::profiles::arethusa_configs {
  include apache
  require site::profiles::deployer
  include site::profiles::arethusa::rvm
  include site::profiles::arethusa::client

  $ruby_version = hiera('arethusa::ruby_version')
  $app_root = hiera('arethusa_configs::app_root')
  $doc_root = hiera('arethusa_configs::doc_root')

  vcsrepo { $app_root:
    ensure   => latest,
    revision => 'master',
    user     => 'deployer',
    provider => git,
    source   => hiera('arethusa_configs::app_repo'),
    require  => User['deployer'],
    notify   => Exec['build-arethusa-configs'],
  }

  exec { 'build-arethusa-configs':
    cwd         => $app_root,
    user        => 'deployer',
    command     => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do rake build",
    require     => [Exec['install-arethusa-client'], Rvm_system_ruby["ruby-${ruby_version}"]],
    notify      => Exec['deploy-arethusa-configs'],
    refreshonly => true
  }

  file { '/usr/local/bin/deploy-arethusa-configs':
    source => 'puppet:///modules/site/profiles/arethusa_configs/deploy-arethusa-configs.sh',
    mode   => '0775',
  }

  exec { 'deploy-arethusa-configs':
    cwd         => '/home/deployer/arethusa-configs',
    command     => "/usr/local/bin/deploy-arethusa-configs ${doc_root}",
    require     => File['/usr/local/bin/deploy-arethusa-configs'],
    refreshonly => true,
  }

  apache::vhost { hiera('arethusa_configs::vhost'):
    port    => '80',
    docroot => "${doc_root}/dist",
  }

  firewall { '100 Allow web traffic for Arethusa Configs':
    proto => 'tcp',
    dport => '80',
  }
}
