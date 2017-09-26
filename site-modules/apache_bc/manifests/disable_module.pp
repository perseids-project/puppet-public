# Disable an Apache module
define apache_bc::disable_module() {
  $apache_pkg = hiera('apache_pkg')
  $apache_path = hiera('apache_path')

  exec { "/usr/sbin/a2dismod ${name}":
    onlyif  => "/bin/ls ${apache_path}/mods-enabled/${name}.load",
    require => Package[$apache_pkg],
  }
}
