# Tomcat-based services
class site::profiles::tomcat7 {
  tomcat::install { '/usr/share/tomcat7':
    install_from_source => false,
    package_ensure      => present,
    package_name        => ['libtomcat7-java','tomcat7-common','tomcat7'],
  }

  exec { 'reload-tomcat':
    command     => '/usr/sbin/service tomcat7 restart',
    refreshonly => true,
  }


  $tomcat_acl = hiera('tomcat_acl')

  $tomcat_acl.each |String $source_ip| {
    firewall { "100 Tomcat access from ${source_ip}":
      proto  => 'tcp',
      dport  => '8080',
      source => $source_ip,
      action => 'accept',
    }
  }

  firewall { '100 Allow HTTP(S) access to Tomcat services':
    chain  => 'INPUT',
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

  # ownership of the logs directory uses
  # hardcoded owner because this is specific to the 
  # package installed and can't be controlled properly
  # by the tomcat puppet module
  file { '/usr/share/tomcat7/logs':
    ensure  => directory,
    owner   => 'tomcat7',
    require => Tomcat::Install['/usr/share/tomcat7'],
  }

  file { '/etc/logrotate.d/tomcat7':
    source => 'puppet:///modules/site/tomcat/tomcat7.logrotate',
  }
}
