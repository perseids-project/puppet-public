# Make regular backups of the Hook DB
class site::profiles::hook::backup {
  $db_name = hiera('hook::db_name')
  $keep_backups_days = hiera('hook::keep_backups_days')
  $s3_bucket = hiera('s3_backup_bucket')

  file { '/backup':
    ensure => directory,
    owner  => 'postgres',
  }

  file { '/usr/local/bin/backup_hook':
    content => epp('site/backup_pg.sh.epp',
    {
      db_name  => $db_name,
      sql_file => "/backup/${db_name}.psql.`/bin/date -Iminutes`",
    }),
    mode    => '0755',
  }

  file { '/var/log/hook_backup.log':
    ensure => present,
    owner  => 'postgres',
  }

  cron { 'backup-hook-db':
    user    => 'postgres',
    command => '/usr/local/bin/backup_hook >/var/log/hook_backup.log 2>&1',
    hour    => '*',
    minute  => '00',
    require => File['/var/log/hook_backup.log'],
  }

  common::duplicity_job { 'hook_db':
    path => '/backup',
  }

  cron { 'prune-hook-db-backups':
    command => "/usr/local/bin/prune_backups /backup hook_db ${keep_backups_days} >>/var/log/hook_backup_prune.log 2>&1",
    hour    => '03',
    minute  => '24',
  }

  file { '/usr/local/bin/check_s3_backup':
    source => 'puppet:///modules/site/check_s3_backup.sh',
    mode   => '0700',
  }

  cron { 'check-hook-backup':
    command => "/usr/local/bin/check_s3_backup s3://${s3_bucket}/hook_db/ >/var/log/check_hook_backup.log 2>&1",
    hour    => '14',
    minute  => '00',
  }
}
