# A profile to include RVM built jruby services
class site::profiles::services::rvm($jruby_version) {
  include rvm

  site::profiles::rubyversion { $jruby_version: }

  rvm_gem { 'bundler':
    ensure       => '1.12.5',
    name         => 'bundler',
    ruby_version => $jruby_version,
    require      => Rvm_system_ruby[$jruby_version],
  }
}
