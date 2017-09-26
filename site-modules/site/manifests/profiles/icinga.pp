# Be the Icinga server
class site::profiles::icinga {
  include icinga::server

  # For AWS monitoring
  include ::site::profiles::aws_sdk
  include ::site::profiles::icinga::aws_creds

  class { '::mysql::server':
    root_password           => hiera('mysql_password'),
    remove_default_accounts => true,
  }

  class { '::mysql::server::monitor':
    mysql_monitor_username => 'monitor',
    mysql_monitor_password => hiera('monitor_password'),
    mysql_monitor_hostname => 'localhost',
  }

  $apache_pkg = hiera('apache_pkg')
  $apache_service = hiera('apache_service')
  $apache_path = hiera('apache_path')

  file { '/usr/local/icinga/etc/htpasswd.users':
    source  => 'puppet:///modules/site/icinga/htpasswd.icinga',
    require => Exec['build-icinga-core'],
  }

  file { "${apache_path}/sites-enabled/icinga.conf":
    source  => 'puppet:///modules/site/icinga/icinga.conf.apache',
    notify  => Service[$apache_service],
    require => Package[$apache_pkg],
  }

  $icinga_config_files = ['icinga.cfg',
                          'cgi.cfg',
                          'hostgroups.cfg',
                          'hosts.cfg',
                          'host_templates.cfg',
                          'resource.cfg',
                          'servicegroups.cfg',
                          'service_templates.cfg',
                          'timeperiods.cfg',
                          'contacts.cfg',
                          'dependencies.cfg',
                          'webchecks.cfg' ]

  site::profiles::icinga_config_file { $icinga_config_files: }

  file { '/usr/local/icinga/etc/commands.cfg':
    content => template('site/icinga/commands.cfg.erb'),
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/services.cfg':
    content => epp('site/icinga/services.cfg.epp',
      {
        'monitor_password' => hiera('monitor_password'),
      }),
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }
}
