class marmotta::ssl {
  include apache

  file { '/etc/ssl/certs/__perseids_org_cert.pem':
    content => lookup('site::ssl::cert_pem'),
  }

  file { '/etc/ssl/certs/__perseids_org_interm.cer':
    content => lookup('site::ssl::interm_cer'),
  }

  file { '/etc/ssl/private/__perseids_org.key':
    content => lookup('site::ssl::key'),
    mode   => '0640',
  }

  apache::vhost { 'marmotta-ssl':
    servername  => hiera('marmotta::vhost'),
    port        => '443',
    docroot     => '/var/www',
    proxy_pass  => hiera('marmotta::proxy_paths'),
    directories => hiera('marmotta::locations'),
    ssl         => true,
    ssl_cert    => '/etc/ssl/certs/__perseids_org_cert.pem',
    ssl_key     => '/etc/ssl/private/__perseids_org.key',
    ssl_chain   => '/etc/ssl/certs/__perseids_org_interm.cer',
  }
}
