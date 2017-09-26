# Make regular backups of the Sosol DB
class site::profiles::sosol::backup {
  $keep_backups_days = hiera('sosol::db::keep_backups_days')
  $s3_bucket = hiera('s3_backup_bucket')

  package { 'mysql-client-5.6': }

  file { '/usr/local/bin/backup_db':
    content => epp('site/backup_db.sh.epp'),
    mode    => '0700',
  }

  file { '/mnt/data/sosol_db_backup':
    ensure => directory,
  }

  cron { 'backup-sosol-db':
    command => '/usr/local/bin/backup_db >/var/log/sosol_backup.log 2>&1',
    hour    => '*',
    minute  => '00',
  }

  common::duplicity_job { 'sosol_db':
    path => '/mnt/data/sosol_db_backup',
  }

  cron { 'prune-sosol-db-backups':
    command => "/usr/local/bin/prune_backups /mnt/data/sosol_db_backup/ sosol_db ${keep_backups_days} >>/var/log/sosol_backup_prune.log 2>&1",
    hour    => '01',
    minute  => '54',
  }

  file { '/usr/local/bin/check_s3_backup':
    source => 'puppet:///modules/site/check_s3_backup.sh',
    mode   => '0700',
  }

  cron { 'check-sosol-backup':
    command => "/usr/local/bin/check_s3_backup s3://${s3_bucket}/sosol_db/ >/var/log/check_sosol_backup.log 2>&1",
    hour    => '20',
    minute  => '00',
  }
}
