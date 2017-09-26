# Run imgup app
class site::profiles::imgup {
  include site::profiles::deployer
  include apache
  include redis
  include rvm

  $rubyversion = hiera('imgup::rubyversion')
  $host = hiera('imgup::vhost')
  $app_dir = hiera('imgup::app_dir')
  $data_dir = hiera('imgup::data_dir')
  site::profiles::rubyversion { "ruby-${rubyversion}": }

  class { 'rvm::passenger::apache':
    version            => '5.1.1',
    ruby_version       => "ruby-${rubyversion}",
    mininstances       => '3',
    maxinstancesperapp => '0',
    maxpoolsize        => '30',
    spawnmethod        => 'smart-lv2',
  }

  ensure_packages([ 'build-essential',
                    'imagemagick'])

  vcsrepo { $app_dir:
    ensure   => present,
    provider => git,
    owner    => 'deployer',
    source   => hiera('imgup::git_url'),
    revision => hiera('imgup::revision'),
    require  => User['deployer'],
  }

  exec { 'install-bundler-imgup':
    cwd     => $app_dir,
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${rubyversion} do gem install bundler",
    require => [Vcsrepo[$app_dir], User['deployer'], Rvm_system_ruby["ruby-${rubyversion}"]],
    unless  => "/usr/local/rvm/bin/rvm ruby-${rubyversion} do gem spec bundler",
  }

  exec { 'bundle-install-imgup':
    cwd     => $app_dir,
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${rubyversion} do bundle install",
    require => Exec['install-bundler-imgup'],
    creates => "${app_dir}/Gemfile.lock",
  }

  file { "${app_dir}/log":
    ensure => directory,
    owner  => 'deployer',
  }

  file { "${app_dir}/log/sidekiq.log":
    ensure => present,
    owner  => 'deployer',
  }

  file {"${app_dir}/upload-mnt":
    ensure => link,
    owner  => 'deployer',
    group  => 'deployer',
    target => "${data_dir}/upload"
  }

  file {"${app_dir}/resize":
    ensure => link,
    owner  => 'deployer',
    group  => 'deployer',
    target => "${data_dir}/resize"
  }

  file { "${app_dir}/conf/imgup.conf.yml":
    content => epp('site/profiles/imgup/imgup.conf.yml',
    {
      'allow_origin' => 'www.perseids.org',
      'url_prefix'   => 'http://www.perseids.org/imgup', # dictated by desire for data consistency with legacy setup
      'app_dir'      => hiera('imgup::app_dir'),
    }),
    owner   => 'deployer',
    require => Vcsrepo[$app_dir],
  }

  exec { 'start-sidekiq':
    cwd     => $app_dir,
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${rubyversion} do bundle exec sidekiq -C conf/sidekiq.yml -d -L log/sidekiq.log -r ${app_dir}/imgup.server.rb",
    unless  => '/bin/ps ax |grep -v grep |grep sidekiq',
    require => Rvm_system_ruby["ruby-${rubyversion}"],
  }

  apache::vhost { $host:
    port           => '80',
    docroot        => "${app_dir}/public",
    docroot_owner  => 'deployer',
    passenger_user => 'deployer',
    passenger_ruby => "/usr/local/rvm/wrappers/ruby-${rubyversion}/ruby",
    directories    =>
    {
      'provider'          => location,
      'path'              => "${app_dir}/public",
      'passenger_enabled' => 'on'
    },
  }

  common::duplicity_job { 'www_imgdata':
    path => hiera('imgup::data_root')
  }

}
