# Individual Duplicity backup job
define common::duplicity_job($path) {
  cron { "backup-${name}":
    command => "/usr/local/bin/duplicity_backup ${name} ${path} >/var/log/duplicity.${name}.log",
    hour    => inline_template('<%= (@hostname.sum + @name.sum ) % 8 %>'),
    minute  => '0',
  }
}
