class sosol::dependencies {

  require site::profiles::deployer
  $jruby_version = hiera('sosol::jruby_version')
  
  rvm_system_ruby { $jruby_version:
    ensure      => present,
    default_use => false,
  }

  rvm_gem { 'bundler':
    ensure       => '1.12.5',
    name         => 'bundler',
    ruby_version => $jruby_version,
    require      => Rvm_system_ruby[$jruby_version],
  }

  class { 'java': }

  ensure_packages(['subversion'])
}
