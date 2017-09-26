# Perseids sosol server
class site::roles::sosol {
  include site::profiles::common
  include site::profiles::sosol
  include site::profiles::tomcat
  include site::profiles::gitserver
}
