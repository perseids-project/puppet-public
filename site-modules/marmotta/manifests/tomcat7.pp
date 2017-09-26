# Tomcat-based services
class marmotta::tomcat7 {
  $home   = $marmotta::home
  $dbuser = $marmotta::dbuser
  $dbpass = $marmotta::dbpass
  $dburl  = $marmotta::dburl
  $context = $marmotta::context

  tomcat::instance { 'marmotta':
    catalina_home  => '/usr/share/tomcat7',
    catalina_base  => '/usr/share/tomcat7',
    user           => 'tomcat7',
    service_name   => 'tomcat7',
    manage_service => true,
    use_init       => true,
    require        => Tomcat::Setenv::Entry['JAVA_OPTS'],
  }

  # the tomcat puppet module does handle setenv ownership
  # well if tomcat is installed from package rather than source
  # it uses the $::tomcat::user variable to set ownership of
  # the setenv file if it doesn't exist yet, but if the puppet  
  # repo has 2 different package-installed versions of tomcat
  # this can't be set right for both.
  # working around it here to create the setenv.sh file first
  # owner the ownership I know to be correct for the version of
  # tomcat I'm using 
  file {'/usr/share/tomcat7/bin/setenv.sh':
    ensure => present,
    owner  => 'tomcat7',
    group  => 'tomcat7',
  }

  tomcat::setenv::entry { 'JAVA_OPTS':
    config_file => '/usr/share/tomcat7/bin/setenv.sh',
    value       => "\"-Xms${marmotta::tomcat7_min_memory} -Xmx${marmotta::tomcat7_max_memory} -XX:MaxPermSize=${marmotta::tomcat7_heap} -Dmarmotta.home=${marmotta::home}\"",
    notify      => Exec['reload-tomcat'],
  }

  file {$marmotta::home:
    ensure  => directory,
    mode    => '0755',
    owner   => 'tomcat7',
    require => Tomcat::Install['/usr/share/tomcat7'],
  }

  file {"${marmotta::home}/system-config.properties":
    content => template('marmotta/system-config.properties.erb'),
    mode    => '0755',
    owner   => 'tomcat7',
    group   => 'tomcat7',
    require => File[$marmotta::home],
  }

  tomcat::war { 'marmotta.war':
    catalina_base => '/var/lib/tomcat7',
    war_source    => "${marmotta::src}/apache-marmotta-3.3.0/marmotta.war",
    notify        => Tomcat::Service['marmotta'],
    require       => [ Archive["${marmotta::src}/marmotta-3.3.0-webapp.zip"],File["${marmotta::home}/system-config.properties"] ]
  }

}
