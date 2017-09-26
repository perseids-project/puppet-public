# spin up a docker container for loris
class site::profiles::digmill::loris {

  class { 'docker':
    dns => '8.8.8.8',
  }

  docker::run { 'loris':
    image => 'lorisimageserver/loris',
    ports => '5004:5004',
  }

  firewall { '100 Loris Access':
    proto  => 'tcp',
    dport  => '5004',
    action => 'accept',
  }

}
