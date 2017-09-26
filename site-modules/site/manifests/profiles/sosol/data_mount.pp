# Mount the data volume for Sosol
class site::profiles::sosol::data_mount {
  if $::perseids_env != 'development' {
    file { '/mnt/data':
      ensure => directory,
    }

    mount { '/mnt/data':
      ensure  => mounted,
      device  => '/dev/xvdf',
      fstype  => 'ext4',
      pass    => 2,
      options => 'defaults,noatime,nobootwait,comment=gitfs',
    }
  }
}
