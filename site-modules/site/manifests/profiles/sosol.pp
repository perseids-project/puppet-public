# Manage the Sosol service
class site::profiles::sosol {
  include ::sosol
  include site::profiles::sosol::backup
  include site::profiles::sosol::data_mount

  firewall { '000 Allow web traffic to sosol':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
