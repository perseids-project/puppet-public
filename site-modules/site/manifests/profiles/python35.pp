# Install Python 3.5
class site::profiles::python35 {
  include apache
  class { 'python':
    version    => 'python3.5',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
    gunicorn   => 'present',
  }
  ensure_packages(hiera('python3_mod_wsgi'))

  class { 'apache::mod::wsgi':
    mod_path     => 'mod_wsgi.so-3.5',
    package_name => hiera('python3_mod_wsgi'),
  }
}
