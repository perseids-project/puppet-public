class sosol::cts {
  $data_dir = '/usr/local/docker-existdb/cts'
  $cts_pubs_url = hiera('sosol::cts_pubs_url')

  file{ $data_dir:
    ensure => directory,
    owner  => 'deployer',
    group  => 'deployer',
  }

  archive{ "${data_dir}/cts-pubs.zip":
    source  => $cts_pubs_url,
    extract => false,
  }

}
