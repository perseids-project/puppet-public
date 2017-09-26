# Perseids Super Services
class site::roles::services {
  include site::profiles::common
  include site::profiles::capitains
  include site::profiles::fuseki
  include site::profiles::llt
  include site::profiles::sg
  include site::profiles::cite_mapper
  include site::profiles::citefusioncoll
  include site::profiles::fghproxy_gh
  include site::profiles::services
}
