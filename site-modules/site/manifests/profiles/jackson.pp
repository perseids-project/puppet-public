# Deploy JackSON
class site::profiles::jackson {
  include site::profiles::deployer
  include apache
  include site::profiles::jackson::imgcollect # because this is the ui for jackson

  require site::profiles::imgup # because we need Ruby

  $rubyversion = hiera('jackson::rubyversion')
  $deploy_dir = hiera('jackson::deploy_dir')
  $host = hiera('jackson::vhost')


  ensure_packages([ 'build-essential',
                    'zlib1g-dev',
                    'libssl1.0.0',
                    'libssl-dev'])

  vcsrepo { $deploy_dir:
    ensure   => present,
    provider => git,
    owner    => 'deployer',
    source   => hiera('jackson::git_url'),
    revision => hiera('jackson::revision'),
    require  => User['deployer'],
    notify   => Exec['build-imgcollect'],
  }

  exec { 'bundle-install-jackson':
    cwd     => $deploy_dir,
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ${rubyversion} do bundle install",
    require => [Vcsrepo[$deploy_dir], User['deployer']],
    creates => "${deploy_dir}/Gemfile.lock",
  }

  file { "${deploy_dir}/JackSON.config.yml":
    content => epp('site/profiles/jackson/JackSON.config.yml',
    {
      'sparql_endpoint' => hiera('jackson::sparql_endpoint'),
      'base_url'        => hiera('jackson::base_url'),
      'data_prefix'     => hiera('jackson::data_prefix'),
    }),
    owner   => 'deployer',
    require => Vcsrepo[$deploy_dir],
    notify  => Apache::Vhost[$host],
  }

  apache::vhost { $host:
    port           => '80',
    docroot        => "${deploy_dir}/public",
    docroot_owner  => 'deployer',
    passenger_user => 'deployer',
    passenger_ruby => "/usr/local/rvm/wrappers/ruby-${rubyversion}/ruby",
    options        => ['MultiViews'],
    directories    =>
    {
      'provider'          => location,
      'path'              => "${deploy_dir}/public",
      'passenger_enabled' => 'on'
    },
  }

  firewall { '100 Allow web traffic for JackSON':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

  common::duplicity_job { 'www_imgjson':
    path => "${deploy_dir}/data"
  }
}
