# Manage sg_reader war
# to test http://host.com/sg/body.1_div1.4_div2.14.html
class site::profiles::sg {
  require site::profiles::deployer
  include site::profiles::java6_openjdk
  include site::profiles::services::rvm
  include site::profiles::services::tomcat

  vcsrepo { '/home/deployer/sg_reader':
    ensure   => latest,
    revision => hiera('sg::app_version'),
    user     => 'deployer',
    provider => 'git',
    source   => hiera('sg::app_repo'),
    require  => User['deployer'],
    notify   => Exec['install-sg'],
  }

  file {'/usr/local/bin/install_sg.sh':
    content => epp('site/profiles/sg/install_sg.sh.epp', {
      'jruby_version' => hiera('site::profiles::services::rvm::jruby_version'),
      'tomcat_pwd'    => hiera('site::profiles::services::tomcat::admin_pwd'),
    }),
    mode    => '0755',
  }

  exec { 'install-sg':
    creates => '/var/lib/tomcat6/webapps/sg.war',
    cwd     => '/home/deployer/sg_reader',
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/install_sg.sh"',
    notify  => Exec['reload-tomcat'],
    require => [File['/usr/local/bin/install_sg.sh'], Tomcat::Config::Server::Tomcat_users['tomcatadminuser']],
    timeout => '600',
  }
}
