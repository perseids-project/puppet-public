# Deploy Perseids SSL cert
class site::profiles::perseids_ssl_cert {
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
}
