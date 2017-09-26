# s3cmd and credentials
class site::profiles::s3cmd {
  package { 's3cmd': }

  file { '/root/.s3cfg':
    content => epp('site/s3cfg.epp'),
  }
}
