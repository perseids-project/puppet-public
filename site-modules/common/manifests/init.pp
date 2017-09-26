# Stuff all servers should have
class common {
  include common::apparmor_disabled
  include common::chkrootkit
  include common::duplicity
  include common::editor
  include common::loggit
  include common::ntp
  include common::slacksay
  include common::utc
  include icinga::target
  include puppet::client
  include snmp
}
