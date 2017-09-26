class morpheus {

  ensure_packages(hiera('morpheus::deps'))
  $base_dir = hiera('morpheus::base_dir')
  $stemlib_dir = hiera('morpheus::stemlib_dir')
  $alpheios_git_url = hiera('morpheus::alpheios_git_url')
  $alpheios_src_dir = hiera('morpheus::alpheios_src_dir')
  $perseus_git_url = hiera('morpheus::perseus_git_url')
  $perseus_src_dir = hiera('morpheus::perseus_src_dir')
  $latin_stemlibs_git_url = hiera('morpheus::latin_stemlibs_git_url')
  $latin_stemlibs_dir = hiera('morpheus::latin_stemlibs_dir')

  file { $base_dir:
    ensure => directory,
  }

  file { $stemlib_dir:
    ensure => directory,
  }

  file {'/usr/local/bin/makemorpheus.sh':
    content => template('morpheus/makemorpheus.sh.erb'),
    mode    => '0755',
  }

  vcsrepo { "${base_dir}/${alpheios_src_dir}":
    ensure   => latest,
    provider => git,
    revision => hiera('morpheus::alpheios_src_tag'),
    source   => $alpheios_git_url,
    require  => File[$base_dir],
  }

  vcsrepo { "${base_dir}/${perseus_src_dir}":
    ensure   => latest,
    provider => git,
    revision => hiera('morpheus::perseus_src_tag'),
    source   => $perseus_git_url,
    require  => File[$base_dir],
    notify   => Exec['makemorpheus'],
  }

  vcsrepo { "${base_dir}/${latin_stemlibs_dir}":
    ensure   => latest,
    revision => hiera('morpheus::stemlibs_src_tag'),
    provider => git,
    source   => $latin_stemlibs_git_url,
    require  => File[$base_dir],
  }

  exec {'makemorpheus':
    command     => '/usr/local/bin/makemorpheus.sh >/tmp/morpheus.log 2>&1',
    path        => "/bin:/usr/bin:${base_dir}/${perseus_src_dir}/bin",
    require     => [ Vcsrepo["${base_dir}/${perseus_src_dir}"],
                      File['/usr/local/bin/makemorpheus.sh']
                    ],
    environment => "MORPHLIB=${base_dir}/${perseus_src_dir}/stemlib",
    refreshonly => true,
  }


  file { "${stemlib_dir}/Greek":
    ensure  => 'link',
    target  => "${base_dir}/${alpheios_src_dir}/dist/stemlib/Greek",
    require => [File[$stemlib_dir], Vcsrepo["${base_dir}/${alpheios_src_dir}"]],
  }

  file { "${stemlib_dir}/Latin":
    ensure  => 'link',
    target  => "${base_dir}/${latin_stemlibs_dir}",
    require => [File[$stemlib_dir], Vcsrepo["${base_dir}/${latin_stemlibs_dir}"]],
  }

}
