# A Tomcat6 instance for Perseids Java Services

class site::profiles::services::tomcat($max_memory, $min_memory, $heap, $admin_pwd, $vhost, $proxy_paths) {
  include site::profiles::tomcat
  include site::profiles::apache

  apache::vhost { $vhost:
    port       => '80',
    docroot    => '/var/www/vhost',
    proxy_pass => $proxy_paths,
    headers    => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ]
  }

  tomcat::instance { 'services':
    catalina_home  => '/usr/share/tomcat6',
    catalina_base  => '/usr/share/tomcat6',
    user           => 'tomcat6',
    manage_service => true,
    use_init       => true,
    service_name   => 'tomcat6',
    require        => Tomcat::Setenv::Entry['JAVA_OPTS'],
  }

  tomcat::config::server::tomcat_users { 'tomcatmanagerguirole':
    ensure        => present,
    catalina_base => '/var/lib/tomcat6',
    element       => 'role',
    element_name  => 'manager-gui',
    manage_file   => true,
    require       => Tomcat::Instance['services'],
  }

  tomcat::config::server::tomcat_users { 'tomcatmanagerscriptrole':
    ensure        => present,
    catalina_base => '/var/lib/tomcat6',
    element       => 'role',
    element_name  => 'manager-script',
    manage_file   => true,
    require       => Tomcat::Instance['services'],
  }

  tomcat::config::server::tomcat_users { 'tomcatadminuser':
    ensure        => present,
    catalina_base => '/var/lib/tomcat6',
    element       => 'user',
    element_name  => 'admin',
    manage_file   => true,
    password      => $admin_pwd,
    roles         => ['manager-gui,manager-script'],
    notify        => Exec['restart-tomcat-load-user'],
    require       => [Tomcat::Instance['services'],
                      Tomcat::Config::Server::Tomcat_users['tomcatmanagerguirole'],
                      Tomcat::Config::Server::Tomcat_users['tomcatmanagerscriptrole']],
  }

  # this is to identify the restart of tomcat to enable the user
  # and roles apart from the restart which is done at other times,
  # such as upon deployment of apps, so that puppet doesn't 
  # postpone it for any other require statements
  exec { 'restart-tomcat-load-user':
    command     => '/usr/sbin/service tomcat6 restart',
    refreshonly => true,
  }


  # the tomcat puppet module does not handle setenv ownership
  # well if tomcat is installed from package rather than source
  # it uses the $::tomcat::user variable to set ownership of
  # the setenv file if it doesn't exist yet, but if the puppet  
  # repo has 2 different package-installed versions of tomcat
  # this can't be set right for both.
  # working around it here to create the setenv.sh file first
  # owner the ownership I know to be correct for the version of
  # tomcat I'm using 
  file {'/usr/share/tomcat6/bin/setenv.sh':
    ensure  => present,
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => Package['tomcat6'],
  }

  tomcat::setenv::entry { 'JAVA_OPTS':
    config_file => '/usr/share/tomcat6/bin/setenv.sh',
    value       => "\"-Xms${min_memory} -Xmx${max_memory} -XX:MaxPermSize=${heap}\"",
    notify      => Exec['reload-tomcat'],
  }
}
