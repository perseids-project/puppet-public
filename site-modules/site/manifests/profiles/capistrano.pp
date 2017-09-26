# Install Capistrano
class site::profiles::capistrano {
  site::profiles::rubyversion { 'ruby-2.0': }

  rvm_gem { 'ruby-2.0/capistrano':
    ensure  => installed,
    require => Rvm_system_ruby['ruby-2.0'],
  }
}
