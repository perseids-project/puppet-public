# Git repo integrity checker
class site::profiles::gitserver::motherfsck {
  $motherfsck_gc = hiera('motherfsck_gc')

  file { '/usr/local/bin/motherfsck':
    source => 'puppet:///modules/site/gitserver/motherfsck.rb',
    mode   => '0755',
  }

  if $motherfsck_gc {
    $gc_clause = '--gc'
  } else {
    $gc_clause = ''
  }

  cron { 'motherfsck':
    command => "/usr/local/bin/motherfsck ${gc_clause} /mnt/data/gitrepo/data >/var/log/motherfsck 2>&1",
    weekday => 'Saturday',
    hour    => '07',
    minute  => '16',
  }
}
