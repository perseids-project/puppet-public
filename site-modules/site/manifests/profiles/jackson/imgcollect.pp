# Perseids imgcollect server
class site::profiles::jackson::imgcollect {
  include site::profiles::node::ten
  include site::profiles::deployer

  $jackson_dir = hiera('jackson::deploy_dir')
  $app_dir = "${jackson_dir}/public/apps/imgcollect"

  file { '/usr/local/bin/build_imgcollect':
    content => epp('site/profiles/jackson/imgcollect/build_imgcollect.sh.epp',
    {
      'node_version' => hiera('jackson::nodeversion'), }),
    mode    => '0775',
  }

  exec { 'build-imgcollect':
    cwd     => $app_dir,
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/build_imgcollect"',
    require => [Vcsrepo[$jackson_dir],File['/usr/local/bin/build_imgcollect']],
    creates => "${app_dir}/bower_components",
    notify  => File["${app_dir}/angular/config.js"],
  }

  file { "${app_dir}/angular/config.js":
    content => epp('site/profiles/jackson/imgcollect/config.js.epp',
    {
      'sparql_endpoint' => hiera('jackson::sparql_endpoint'),
      'base_url'        => hiera('jackson::base_url'),
      'auth_url'        => hiera('jackson::imgcollect::auth_url'),
      'imgup_url'       => 'http://www.perseids.org/imgup', #legacy setup dictates
    }),
    owner   => 'deployer',
  }
}
