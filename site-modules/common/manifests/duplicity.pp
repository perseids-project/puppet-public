# Nightly backup to S3
class common::duplicity {
  package {['duplicity',
            'python-boto',
            'python-paramiko',
            'python-gobject-2']:
    ensure => installed,
  }

  $aws_access_key = hiera('aws_access_key')
  $aws_secret_key = hiera('aws_secret_key')
  $s3_bucket = hiera('s3_backup_bucket')
  $full_backup_every = hiera('full_backup_every')
  $prune_backups_after = hiera('prune_backups_after')

  file { '/usr/local/bin/duplicity_backup':
    content => template('common/duplicity_backup.sh.erb'),
    mode    => '0755',
  }

  file { '/usr/local/bin/duplicity_find_file':
    content => template('common/duplicity_find_file.rb.erb'),
    mode    => '0755',
  }

  file { '/usr/local/bin/duplicity_list':
    content => template('common/duplicity_list.rb.erb'),
    mode    => '0755',
  }

  file { '/usr/local/bin/duplicity_restore':
    content => template('common/duplicity_restore.rb.erb'),
    mode    => '0755',
  }

  file { '/usr/local/bin/prune_backups':
    content => template('common/prune_backups.rb.erb'),
    mode    => '0755',
  }
}
