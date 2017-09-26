# Perseids Capitains service
class site::profiles::capitains {
  include site::profiles::apache
  include site::profiles::perseids_ssl_cert
  include capitains
}
