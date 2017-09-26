# Install Python 3
class site::profiles::python3 {
  include apache
  class { 'python':
    version    => 'python3',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
    gunicorn   => 'present',
  }
  ensure_packages(hiera('python3_mod_wsgi'))

  class { 'apache::mod::wsgi':
    mod_path     => 'mod_wsgi.so-3.4',
    package_name => hiera('python3_mod_wsgi'),
  }
}
