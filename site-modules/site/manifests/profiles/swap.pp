# Create and mount a 1GB swapfile
class site::profiles::swap {
  file { '/usr/local/bin/create_swap':
    source => 'puppet:///modules/site/create_swap.sh',
    mode   => '0755',
  }

  exec { 'create-and-mount-swap':
    command => '/usr/local/bin/create_swap',
    unless  => '/bin/grep swapfile /etc/fstab',
    require => File['/usr/local/bin/create_swap'],
  }
}
