# Manage Sosol Dev Setup
class sosoldev {
  include sosol::dependencies
  include sosol::app
  include sosol::exist
  include sosoldev::certs
  include sosoldev::web
  include sosoldev::pca
  include sosoldev::arethusa
  include sosoldev::llt

}
