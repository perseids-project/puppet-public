# annotation server
class site::roles::annotation {
  include site::profiles::common
  include site::profiles::tomcat7
  include site::profiles::postgres
  include site::profiles::marmotta
  include site::profiles::imgup
  include site::profiles::jackson
  include site::profiles::arethusa
  include site::profiles::joth
  include site::profiles::pca
  include site::profiles::pubs
  include site::profiles::arethusa_configs
  include site::profiles::www
}
