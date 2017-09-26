# Manage Cite Fusion Coll War
class site::profiles::citefusioncoll {
  include site::profiles::java6_openjdk
  include site::profiles::services::tomcat
  require site::profiles::deployer

  vcsrepo { '/home/deployer/citefusioncoll':
    ensure   => latest,
    revision => hiera('citefusioncoll::app_version'),
    user     => 'deployer',
    provider => 'git',
    source   => hiera('citefusioncoll::app_repo'),
    require  => User['deployer'],
    notify   => Exec['install-citefusioncoll'],
  }

  file {'/usr/local/bin/install_citefusioncoll.sh':
    content => epp('site/profiles/citefusioncoll/install_citefusioncoll.sh.epp', {
      'tomcat_pwd' => hiera('site::profiles::services::tomcat::admin_pwd'),
    }),
    mode    => '0755',
  }

  exec {'install-citefusioncoll':
    creates => '/var/lib/tomcat6/webapps/citefusioncoll-0.2.0.war',
    cwd     => '/home/deployer/citefusioncoll',
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/install_citefusioncoll.sh"',
    notify  => Exec['reload-tomcat'],
    require => [File['/usr/local/bin/install_citefusioncoll.sh'], Tomcat::Config::Server::Tomcat_users['tomcatadminuser']],
    timeout => '600',
  }
}
