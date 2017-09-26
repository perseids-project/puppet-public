# Make regular backups of the Marmotta DB
class site::profiles::marmotta::backup {
  $db_name = hiera('marmotta::dbname')
  $keep_backups_days = hiera('marmotta::keep_backups_days')
  $s3_bucket = hiera('s3_backup_bucket')

  file { '/mnt/data':
    ensure => directory,
    owner  => 'postgres',
  }

  file { '/mnt/data/marmotta_db_backup':
    ensure => directory,
    owner  => 'postgres',
  }

  file { '/var/log/marmotta_backup.log':
    ensure => present,
    owner  => 'postgres',
  }

  file { '/usr/local/bin/backup_marmotta':
    content => epp('site/backup_pg.sh.epp',
    {
      db_name  => $db_name,
      sql_file => "/mnt/data/marmotta_db_backup/${db_name}.psql.`/bin/date -Iminutes`",
    }),
    mode    => '0755',
  }

  cron { 'backup-marmotta-db':
    user    => 'postgres',
    command => '/usr/local/bin/backup_marmotta >/var/log/marmotta_backup.log 2>&1',
    hour    => '*',
    minute  => '00',
    require => File['/var/log/marmotta_backup.log'],
  }

  common::duplicity_job { 'marmotta_db':
    path => '/mnt/data/marmotta_db_backup',
  }

  cron { 'prune-marmotta-db-backups':
    command => "/usr/local/bin/prune_backups /mnt/data/marmotta_db_backup marmotta_db ${keep_backups_days} >>/var/log/marmotta_backup_prune.log 2>&1",
    hour    => '03',
    minute  => '54',
  }

  file { '/usr/local/bin/check_s3_backup':
    source => 'puppet:///modules/site/check_s3_backup.sh',
    mode   => '0700',
  }

  cron { 'check-marmotta-backup':
    command => "/usr/local/bin/check_s3_backup s3://${s3_bucket}/marmotta_db/ >/var/log/check_marmotta_backup.log 2>&1",
    hour    => '10',
    minute  => '00',
  }
}
