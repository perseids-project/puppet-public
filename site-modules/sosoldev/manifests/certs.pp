# SSL Certs for Shibboleth

class sosoldev::certs {

  # shibboleth certs keys
  file { '/etc/ssl/private':
    ensure  => directory,
  }

  file { '/etc/ssl/certs/sosol-test.perseids.pem':
    content => lookup('sosol::shib::perseids_test_cer'),
    require => File['/etc/ssl/private'],
  }

  file { '/etc/ssl/private/private-test.key':
    content => lookup('sosol::shib::test_key'),
    mode    => '0640',
    require => File['/etc/ssl/private'],
  }

}
