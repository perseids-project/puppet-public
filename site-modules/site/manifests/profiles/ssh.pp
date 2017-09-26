# Run SSH daemon
class site::profiles::ssh {
  service { 'ssh':
    ensure => running,
  }

  file { '/etc/pam.d/sshd':
    source => 'puppet:///modules/site/profiles/sshd.pam',
  }

  firewall { '100 allow SSH':
    chain  => 'INPUT',
    state  => ['NEW'],
    dport  => '22',
    proto  => 'tcp',
    action => 'accept',
  }

  file { '/etc/ssh/sshd_config':
    content => epp('site/profiles/sshd_config.epp',
      {
        'allow_users' => lookup('allow_users', Array[String], 'unique'),
      }),
    notify  => Service['ssh'],
  }
}
