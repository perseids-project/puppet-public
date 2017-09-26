# Manage puppetlabs-firewall global setup
resources { 'firewall':
    purge => true,
}

Firewall {
  before  => Class['common::firewall_post'],
  require => Class['common::firewall_pre'],
}

class { ['common::firewall_pre', 'common::firewall_post']: }
class { 'firewall': }
