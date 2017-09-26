# Automatically apply APT (security) updates
class site::profiles::unattended_upgrades {
  ensure_packages(['unattended-upgrades'])

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    content => epp('site/unattended-upgrades.apt.conf.epp',
    {
      sysadmins => hiera('sysadmins'),
    }),
  }

  file { '/etc/apt/apt.conf.d/10periodic':
    source => 'puppet:///modules/site/10periodic.apt.conf',
  }

  file { '/etc/logrotate.d/unattended-upgrades':
    ensure  => absent,
    require => Package['unattended-upgrades'],
  }
}
