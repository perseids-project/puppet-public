# Manage the Sosol Development Profile
class site::profiles::sosoldev {
  require site::profiles::deployer
  include ::sosoldev

  firewall { '000 Allow web traffic to sosol dev':
    proto  => 'tcp',
    dport  => ['8080','443','3000','8800'],
    action => 'accept',
  }
}
