# A single config file for Icinga
define site::profiles::icinga_config_file() {
  file { "/usr/local/icinga/etc/${name}":
    source  => "puppet:///modules/site/icinga/${name}",
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }
}
