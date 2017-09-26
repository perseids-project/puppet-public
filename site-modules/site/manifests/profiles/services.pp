# Apache Proxy for Perseids Services
# For legacy reasons we have a proxy answering for a number of services
# on a single host (i.e. services.perseids.org)
# we also have most them answering now on their own hosts to keep the puppet
# configuration cleaner and more modularized but we retain the aggregate proxy setup
class site::profiles::services {
  include site::profiles::apache
  include site::profiles::perseids_ssl_cert

  apache::vhost { hiera('site::profiles::services::vhost'):
    port       => '80',
    docroot    => '/var/www/vhost',
    proxy_pass => hiera('site::profiles::services::proxy_paths'),
    headers    => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS, DELETE, PUT'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
  }

  apache::vhost { 'services-ssl':
    servername => hiera('site::profiles::services::vhost'),
    port       => '443',
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key    => '/etc/ssl/private/__perseids_org.key',
    ssl_chain  => '/etc/ssl/certs/__perseids_org_interm.cer',
    docroot    => '/var/www/vhost',
    proxy_pass => hiera('site::profiles::services::proxy_paths'),
    headers    => [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS, DELETE, PUT'",
      "set Access-Control-Allow-Headers 'Origin, X-Requested-With, Content-Type, Accept'"
    ],
  }
}
