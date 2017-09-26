# Perseids Postgres server
class site::profiles::postgres {
  $postgres_acl = hiera('postgres_acl')

  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '*',
    postgres_password          => hiera('postgres::password'),
  }

  $postgres_acl.each |String $source_ip| {
    firewall { "100 Postgres access from ${source_ip}":
      proto  => 'tcp',
      dport  => '5432',
      source => $source_ip,
      action => 'accept',
    }
  }
}
