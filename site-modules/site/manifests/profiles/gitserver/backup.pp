# Back up Git repos
class site::profiles::gitserver::backup {
  include common::duplicity

  common::duplicity_job { 'git':
    path => '/mnt/data/gitrepo/data',
  }
}
