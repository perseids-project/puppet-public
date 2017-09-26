# instal the arethusa-cli tool
class site::profiles::arethusa::client {
  require site::profiles::deployer

  $ruby_version = hiera('arethusa::ruby_version')
  exec { 'install-nokogiri':
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem install nokogiri -v 1.6.7.2",
    require => Rvm_system_ruby["ruby-${ruby_version}"],
    unless  => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem spec nokogiri",
    notify  => Exec['install-arethusa-client'],
  }

  exec { 'install-arethusa-client':
    user    => 'deployer',
    command => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem install arethusa-client -v 0.1.17",
    require => Rvm_system_ruby["ruby-${ruby_version}"],
    unless  => "/usr/local/rvm/bin/rvm ruby-${ruby_version} do gem spec arethusa-client",
  }

}
