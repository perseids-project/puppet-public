# Monitor server
class site::roles::monitor {
  include ::site::profiles::common
  include ::site::profiles::icinga
}
