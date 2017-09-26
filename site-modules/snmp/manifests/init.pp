# Run an SNMP daemon
class snmp {
  $snmp_community = hiera('snmp_community')

  package { 'snmpd': ensure => installed }

  service { 'snmpd':
    ensure  => running,
    enable  => true,
    require => Package['snmpd'],
  }

  file { '/etc/snmp/snmpd.conf':
    content => template('snmp/snmpd.conf.erb'),
    require => Package['snmpd'],
    notify  => Service['snmpd'],
    mode    => '0600',
  }
}
