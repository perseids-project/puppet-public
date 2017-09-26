class bsp {
  include bsp::firewall
  include bsp::dependencies

  $bsp_dir = hiera('bsp::base_dir')
  $src_dir = hiera('bsp::src_dir')
  $work_dir = hiera('bsp::work_dir')
  $maven_version = hiera('bsp::maven_version')
  $maven_base_url = hiera('bsp::maven_base_url')
  $smx_home = hiera('bsp::smx_home')
  $m2_home = hiera('bsp::m2_home')
  $smx_cache_archive = hiera('bsp::smx_cache_archive')
  $bsp_repo_archive = hiera('bsp::repo_archive')
  $fuse_version = hiera('bsp::fuse_version')
  $fuse_base_url = hiera('bsp::fuse_base_url')


  user::bundle { 'smx':
    fullname => 'SMX user',
  }

  file { '/home/smx/.bashrc':
    content => template('site/bsp/bashrc.erb'),
    require => User::Bundle['smx'],
  }

  file { [$bsp_dir,
          $src_dir,
          $work_dir,
          "${work_dir}/cache",
          "${work_dir}/cache/BSP",
          "${work_dir}/logs",
          "${work_dir}/logs/security",
          "${work_dir}/policies",
          "${work_dir}/mavenRepo"]:
    ensure => directory,
    owner  => 'smx',
    group  => 'smx',
  }

  archive { "${bsp_dir}/${fuse_version}.tar.gz":
    source       => "${fuse_base_url}/${fuse_version}.tar.gz",
    extract      => true,
    user         => 'smx',
    extract_path => $bsp_dir,
    require      => File[$bsp_dir],
  }

  archive { "${bsp_dir}/${maven_version}.tar.gz":
    source       => "${maven_base_url}/${maven_version}.tar.gz",
    extract      => true,
    extract_path => $bsp_dir,
    user         => 'smx',
    require      => File[$bsp_dir],
  }

  file { "${smx_home}/etc/org.apache.cxf.osgi.cfg":
    content => template('site/bsp/org.apache.cxf.osgi.cfg.erb'),
    owner   => 'smx',
    require => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
  }

  file { "${smx_home}/etc/config.properties":
    content => template('site/bsp/config.properties.erb'),
    owner   => 'smx',
    require => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
  }

  file { "${smx_home}/etc/org.apache.karaf.features.cfg":
    content => template('site/bsp/org.apache.karaf.features.cfg.erb'),
    owner   => 'smx',
    require => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
  }

  file { "${smx_home}/etc/org.ops4j.pax.web.cfg":
    content => template('site/bsp/org.ops4j.pax.web.cfg.erb'),
    owner   => 'smx',
    require => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
  }

  file { '/etc/init.d/fuse-smx':
    source => 'puppet:///modules/site/bsp/fuse-smx',
    mode   => '0755',
  }

  file { '/etc/fuse-smx':
    content => template('site/bsp/fuse-smx'),
  }

  file { "${m2_home}/conf/settings.xml":
    content => template('site/bsp/settings.xml.erb'),
    owner   => 'smx',
    require => Archive["${bsp_dir}/${maven_version}.tar.gz"],
  }

  vcsrepo { $src_dir:
    ensure   => present,
    provider => svn,
    source   => 'svn://svn.code.sf.net/p/projectbamboo/code/',
    notify   => Exec['install-db'],
  }

  exec { 'install-db':
    cwd         => "${src_dir}/platform-services/bsp/trunk/bsp-ddl/src/main/resources",
    user        => 'postgres',
    command     => 'psql -W -f create-BSP_V1.sql && psql -W -f person-tables.sql BSP_V1_TEST && psql -W -f notification-tables.sql BSP_V1_TEST && psql -W -f cache-tables.sql BSP_V1_TEST && psql -W -f utility.protected-resource.domain.sql BSP_V1_TEST',
    refreshonly => true,
  }

  file {"${smx_home}/data/cache":
    ensure  => directory,
    require => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
    owner   => 'smx',
  }

  archive { "${bsp_dir}/smxcache.tgz":
    source       => $smx_cache_archive,
    extract      => true,
    extract_path => "${smx_home}/data/cache",
    user         => 'smx',
    require      => File["${smx_home}/data/cache"],
  }

  archive { "${bsp_dir}/mavenrepo.tgz":
    source       => $bsp_repo_archive,
    extract      => true,
    extract_path => "${work_dir}/mavenRepo",
    user         => 'smx',
    require      => Archive["${bsp_dir}/${fuse_version}.tar.gz"],
  }

  file { "${work_dir}/policies/PermitAllServices.xml":
    source => "${src_dir}/platform-services/bsp/trunk/bsp/utility-services/policy-service/policy-service-domain/src/test/resources/policies/PermitAllServices.xml"
  }

  service {'fuse-smx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    pattern    => 'org.apache.karaf.main.Main',
    require    => [ File['/etc/fuse-smx'],
                    File['/etc/init.d/fuse-smx'],
                    File["${m2_home}/conf/settings.xml"],
                    Exec['install-db'],
                    Archive["${bsp_dir}/smxcache.tgz"],
                    Archive["${bsp_dir}/mavenrepo.tgz"]
                  ]
  }
}
