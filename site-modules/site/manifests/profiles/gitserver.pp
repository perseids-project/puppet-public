# Be the Git server
class site::profiles::gitserver {
  include site::profiles::gitserver::motherfsck
  include site::profiles::gitserver::backup
}
