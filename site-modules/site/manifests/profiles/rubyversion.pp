# Install a given Ruby/Bundler version
define site::profiles::rubyversion() {
  include rvm

  $ruby = $name

  rvm_system_ruby { $ruby:
    ensure      => present,
    default_use => false,
  }
}
