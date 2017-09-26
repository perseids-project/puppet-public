node 'monitor' {
  include site::roles::monitor
  include site::roles::aws_orchestrator
}

node 'hook' {
  include site::roles::hook
}

node 'services' {
  include site::roles::services
}

node /sosol/ {
  include site::roles::sosol
}

node 'build' {
  include site::roles::build
}

node /playpen/ {
  include site::roles::playpen
}

node /digmill/ {
  include site::roles::digmill
}

node /^annotation/ {
  include site::roles::annotation
}

node /collections/ {
  include site::roles::collections
}

node 'quickstart' {
  include site::profiles::common
}

node 'john-play' {
  include site::profiles::common
}

node 'morph' {
  include site::roles::morphology
}

node 'vagrant' {
  include site::roles::vagrant
}

