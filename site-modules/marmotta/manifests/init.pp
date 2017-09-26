# Manage Marmotta
class marmotta( $dbuser,
                $dbpass,
                $dburl,
                $dbname,
                $context,
                $src,
                $home,
                $tomcat7_max_memory,
                $tomcat7_min_memory,
                $tomcat7_heap ){
  include marmotta::tomcat7
  include marmotta::web
  include marmotta::ssl

  # this is very weird but archive module doesn't seem to
  # properly ensure unzip is available
  ensure_packages(['unzip'])

  postgresql::server::db { $dbname :
    user     => $dbuser,
    password => postgresql_password($dbuser, $dbpass)
  }

  archive { "${src}/marmotta-3.3.0-webapp.zip":
    ensure       => present,
    creates      => "${src}/apache-marmotta-3.3.0/marmotta.war",
    source       => 'http://mirrors.gigenet.com/apache/marmotta/3.3.0/apache-marmotta-3.3.0-webapp.zip',
    extract_path => $src,
    extract      => true,
  }

}
