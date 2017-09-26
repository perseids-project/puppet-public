class site::profiles::node::ten {
  include site::profiles::node
  nvm::node::install { '0.10.46':
    user        => 'deployer',
    set_default => false,
  }
}
