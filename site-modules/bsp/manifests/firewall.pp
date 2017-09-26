class bsp::firewall {

  $fuse_acl = hiera('bsp::fuse_acl')
  $fuse_acl.each |String $source_ip| {
    firewall { "100 Fuse access from ${source_ip}":
      proto  => 'tcp',
      dport  => '8181',
      source => $source_ip,
      action => 'accept',
    }
  }
  firewall { '100 Allow HTTP to morphology':
    chain  => 'INPUT',
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }

}
