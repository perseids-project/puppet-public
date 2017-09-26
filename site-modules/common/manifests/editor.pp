# Sets a sensible editor in user environments
class common::editor {
  file { '/etc/profile.d/editor.sh':
    source => 'puppet:///modules/common/editor.sh',
  }
}
