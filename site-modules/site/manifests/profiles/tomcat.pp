# Tomcat-based services
class site::profiles::tomcat {
  tomcat::install { '/usr/share/tomcat6':
    install_from_source => false,
    package_ensure      => present,
    package_name        => ['tomcat6', 'tomcat6-admin'],
  }

  exec { 'reload-tomcat':
    command     => '/usr/sbin/service tomcat6 restart',
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

  firewall { '100 Allow Shibboleth access to Tomcat services':
    chain  => 'INPUT',
    proto  => 'tcp',
    dport  => '8443',
    action => 'accept',
  }

  file { '/usr/share/tomcat6/logs':
    ensure  => directory,
    owner   => 'tomcat6',
    require => Tomcat::Install['/usr/share/tomcat6'],
  }

  file { '/etc/logrotate.d/tomcat6':
    source => 'puppet:///modules/site/tomcat/tomcat6.logrotate',
  }
}
