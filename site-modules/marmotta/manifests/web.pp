class marmotta::web {
  include site::profiles::apache

  $marmotta_vhost = hiera('marmotta::vhost')

  apache::vhost { $marmotta_vhost:
    default_vhost => true,
    port          => '80',
    docroot       => '/var/www',
    proxy_pass    => hiera('marmotta::proxy_paths'),
    directories   => hiera('marmotta::locations'),
  }

  file {'/var/www/index.html':
    content => template('marmotta/index.html.erb'),
    mode    => '0666',
    require => Apache::Vhost[$marmotta_vhost],
  }
}
