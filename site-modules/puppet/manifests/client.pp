# Be a git-based Puppet client
class puppet::client {
  $puppet_agent_version = hiera('puppet_agent_version')

  exec { 'download-and-install-puppet-repo':
    cwd     => '/root',
    command => "/usr/bin/wget -O puppetlabs-release-pc1.deb https://apt.puppetlabs.com/puppetlabs-release-pc1-${::lsbdistcodename}.deb && PATH=/sbin:\$PATH /usr/bin/dpkg -i puppetlabs-release-pc1.deb && apt-get update",
    unless  => "dpkg -l puppetlabs-release-pc1 |grep ii |grep ${::lsbdistcodename}",
  }

  package { 'puppet-agent':
    ensure  => $puppet_agent_version,
    require => Exec['download-and-install-puppet-repo'],
  }

  file_line { 'disable reports':
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    line    => 'report = false',
    require => Package['puppet-agent'],
  }

  ensure_packages(['r10k'],
    {
      'provider' => 'puppet_gem',
    }
  )

  service { ['puppet', 'mcollective', 'pxp-agent']:
    ensure  => stopped, # Puppet runs from cron
    enable  => false,
    require => Package['puppet-agent'],
  }

  cron { 'run-puppet':
    ensure  => present,
    command => '/usr/local/bin/loggit run-puppet /usr/local/bin/run-puppet',
    minute  => '*/10',
    hour    => '*',
  }

  file { '/usr/local/bin/run-puppet':
    source => 'puppet:///modules/puppet/run-puppet.sh',
    mode   => '0755',
  }

  file { '/usr/local/bin/papply':
    content => epp('puppet/papply.sh.epp',
                    {'aws_region' => hiera('aws::region')}),
    mode    => '0755',
  }

  file { '/usr/local/bin/plock':
    source => 'puppet:///modules/puppet/plock.sh',
    mode   => '0755',
  }

  file { '/usr/local/bin/punlock':
    source => 'puppet:///modules/puppet/punlock.sh',
    mode   => '0755',
  }

  file { '/usr/local/bin/git_is_up_to_date':
    source => 'puppet:///modules/puppet/git_is_up_to_date.sh',
    mode   => '0755',
  }

  file { '/tmp/puppet.lastrun':
    content => inline_template('<%= Time.now %>'),
    backup  => false,
  }

  firewall { '100 allow SSH (for Git)':
    chain  => 'OUTPUT',
    state  => ['NEW'],
    dport  => '22',
    proto  => 'tcp',
    action => 'accept',
  }
}
