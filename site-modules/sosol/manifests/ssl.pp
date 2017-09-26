# SSL vhost and certs for Sosol
class sosol::ssl {
  include site::profiles::perseids_ssl_cert

  $sosol_app_url = hiera('sosol::app_url')

  apache::vhost { 'sosol-ssl':
    servername      => $sosol_app_url,
    default_vhost   => true,
    port            => '443',
    docroot         => '/var/www',
    ssl             => true,
    ssl_cert        => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key         => '/etc/ssl/private/__perseids_org.key',
    ssl_chain       => '/etc/ssl/certs/__perseids_org_interm.cer',
    options         => ['-Indexes'],
    setenvif        => ['Origin "^(.*\.perseids\.org)$" ORIGIN_SUB_DOMAIN=$1'],
    headers         => [
      'set Access-Control-Allow-Origin: "%{ORIGIN_SUB_DOMAIN}e" env=ORIGIN_SUB_DOMAIN',
      'always set Access-Control-Allow-Methods "POST, GET, OPTIONS"',
      'set Access-Control-Allow-Headers: "Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token, Authorization"',
      'set Access-Control-Allow-Credentials: true'],
    error_documents => hiera('sosol::error_documents'),
    proxy_pass      => hiera('sosol::proxy_paths'),
  }
}
