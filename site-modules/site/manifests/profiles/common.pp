# Common profile for all servers
class site::profiles::common {
  include common
  include site::profiles::s3cmd
  include site::profiles::ssh
  include site::profiles::swap
  include site::profiles::sudoers
  include site::profiles::unattended_upgrades
  include site::profiles::users
  include site::profiles::vim

  firewall { '100 Allow ICMP in':
    chain  => 'INPUT',
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '100 Allow ICMP out':
    chain  => 'OUTPUT',
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '100 Allow TCP/UDP traffic out':
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }

  package { 'update-notifier-common':
    ensure => purged,
  }

}
