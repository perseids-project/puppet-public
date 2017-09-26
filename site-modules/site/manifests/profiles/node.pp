# A profile to include NVM and node
class site::profiles::node {
  require site::profiles::deployer

  class { 'nvm':
    user    => 'deployer',
    home    => '/home/deployer',
    version => 'v0.33.0',
  }

}
