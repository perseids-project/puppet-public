# manage rvm for arethusa
class site::profiles::arethusa::rvm {
  include rvm

  $ruby_version = hiera('arethusa::ruby_version')

  site::profiles::rubyversion { "ruby-${ruby_version}": }
}
