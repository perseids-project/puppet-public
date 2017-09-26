# Manage cite_mapper service
# to test http://host.com/cite_mapper/find_cite?cite=urn:cts:greekLit:tlg0085.tlg004.perseus-grc2
class site::profiles::cite_mapper {
  require site::profiles::deployer
  include site::profiles::java6_openjdk
  include site::profiles::services::rvm
  include site::profiles::services::tomcat

  vcsrepo { '/home/deployer/cite_mapper':
    ensure   => latest,
    revision => 'master',
    user     => 'deployer',
    provider => 'git',
    source   => hiera('cite_mapper::app_repo'),
    require  => User['deployer'],
    notify   => Exec['install-cite_mapper'],
  }

  file {'/usr/local/bin/install_cite_mapper.sh':
    content => epp('site/profiles/cite_mapper/install_cite_mapper.sh.epp', {
      'jruby_version' => hiera('site::profiles::services::rvm::jruby_version'),
      'tomcat_pwd'    => hiera('site::profiles::services::tomcat::admin_pwd'),
    }),
    mode    => '0755',
  }

  exec {'install-cite_mapper':
    creates => '/var/lib/tomcat6/webapps/cite_mapper.war',
    cwd     => '/home/deployer/cite_mapper',
    user    => 'deployer',
    command => 'bash --login "/usr/local/bin/install_cite_mapper.sh"',
    notify  => Exec['reload-tomcat'],
    require => [File['/usr/local/bin/install_cite_mapper.sh'], Tomcat::Config::Server::Tomcat_users['tomcatadminuser']],
    timeout => '600',
  }
}
