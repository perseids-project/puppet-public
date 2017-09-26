class site::profiles::apache {
  class { 'apache':
    default_vhost => false,
  }
  class { 'apache::mod::proxy_http': }
}
