# Manage Sosol app
class sosol {
  include sosol::dependencies
  include sosol::tomcat
  include sosol::app
  include sosol::exist
  include sosol::web

}
