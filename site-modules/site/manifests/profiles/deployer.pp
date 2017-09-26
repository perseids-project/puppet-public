# Deployer user
class site::profiles::deployer {
  include rvm

  accounts::user { 'deployer':
    comment => 'The Deployer',
    groups  => ['rvm'],
    sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSiMCwbwAi2Xd3e+0DHDpgKD4b+rhsGVds2eMlI6s8LH3Zfkp/jrMp4BVLvod1U8bS8UmoZfNyNZYULWU1FTfVSUT414T57IGEnkRkp/miXkQqqKX31hGBlFO6GUP6l5oGOT7RpZWggQp5jm43aWtNeMUy0PwykRqJDwHwSYFPDL/tFW/wSle8CbezUI0iFN4whj2ZlKrH/DpTgtWJxstnK5eB7RaCNfwgbtUZ8W3GkG5wnEcZRxSGSKVTsUkvrtRY6mz2W/KdbmGcJ5lgAc9VB6OzmN1RIRVtfaQGoKSL5p7nl0c0MZwy+YAqZ1knd4C+/O2tA/C514tuvz+1Gn7B root@build'],
  }
}
