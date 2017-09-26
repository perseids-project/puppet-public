# SSL vhost and certs for Sosol
class sosoldev::ssl {

  $sosol_app_url = 'localhost'

  file { '/etc/ssl/certs/sosol_perseids_org_cert.cer':
    source => 'puppet:///modules/sosol/sosol_perseids_org_cert.cer',
  }

  file { '/etc/ssl/certs/sosol_perseids_org_intermediate.cer':
    source => 'puppet:///modules/sosol/sosol_perseids_org_intermediate.cer',
  }

  file { '/etc/ssl/private/sosol.perseids.org.key':
    source => 'puppet:///modules/sosol/sosol.perseids.org.key',
    mode   => '0640',
  }

  apache::vhost { 'sosol-ssl':
    servername      => $sosol_app_url,
    default_vhost   => true,
    port            => '443',
    docroot         => '/var/www',
    ssl             => true,
    ssl_cert        => '/etc/ssl/certs/sosol_perseids_org_cert.cer',
    ssl_key         => '/etc/ssl/private/sosol.perseids.org.key',
    ssl_chain       => '/etc/ssl/certs/sosol_perseids_org_intermediate.cer',
    options         => ['-Indexes'],
    headers         => [
      'set Access-Control-Allow-Origin: "*"',
      'always set Access-Control-Allow-Methods "POST, GET, OPTIONS"',
      'set Access-Control-Allow-Headers: "Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token, Authorization"',
      'set Access-Control-Allow-Credentials: true'],
    error_documents => hiera('sosol::error_documents'),
    proxy_pass      => hiera('sosoldev::proxy_paths'),
  }
}
