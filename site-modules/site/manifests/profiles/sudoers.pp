# Manage sudoers entries
class site::profiles::sudoers {
  sudo::conf { 'secure_path':
    content  => 'Defaults      secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/puppet/bin"',
    priority => 0,
  }
  sudo::conf { 'nagios':
    content  => 'nagios      ALL = (ALL) NOPASSWD: /usr/local/bin/show_puppet_branch',
    priority => 0,
  }
  $sudoers = lookup('sudoers', Array[String], 'unique', [])
  $sudoers.each | String $user | {
    sudo::conf { $user:
      content  => "${user} ALL=(ALL) NOPASSWD: ALL",
      priority => 10,
    }
  }
}
