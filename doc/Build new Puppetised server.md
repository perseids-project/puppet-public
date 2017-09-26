# Build new server with Puppet

## Add a node definition

If the new server is a replacement for an existing server, or matches a node already defined by means of a wildcard (for example `/monitor*/`) there is no need to add a distinct node definition for it. Otherwise:

1. Add a node definition for the new instance in `manifests/site.pp`. For example:

        node 'monitor' {
          include site::roles::monitor
        }

    
1. Commit and push your changes to the Puppet repo.

## Launch server

1. Launch a new instance via the AWS control panel. 

  1.1. Select an appropriate size and use the `perseids-quickstart` AMI ('My AMIs'). 
  
  1.2. Enable Public IP
  
  1.3  Tag the instance with a name (if the instance is going to be kept, this will be the name referenced in the hiera config for it)
  
  1.4. Use the `open` security group (Puppet manages firewalls via iptables). 
  
  1.5. Use the `perseidskey.pem` access key. This file should be in the directory above your Puppet checkout.

1. When the instance is ready, note its public IP. 

## Set hostname and reapply Puppet

1. Connect to the instance's public IP via SSH (your user account and key will already be configured on the instance).

1. Set the hostname you want (eg `sosol`):

        hostname sosol
1. cd to the /etc/puppetlabs/code/environments/production directory and do a `git pull` to get the latest copy of the master branch of the repo.

1. Apply Puppet:

        papply

When Puppet's run is complete, your server should be ready.

## Bootstrap

If you are using the `perseids-quickstart` AMI, you can skip the bootstrap phase, as the server is already configured with Puppet and it will auto-run a few minutes after starting, to bring the instance up to date with the latest changes from the Git repo.

If you are using another AMI, follow these steps.

### Prerequisites

On your own desktop or laptop, you will need:

 * A copy of the Puppet repo
 * Rake
 * GnuPG
 * A copy of the Perseids Admin GPG secret key (id 33A6B590) installed on your GPG keyring, and the passphrase to unlock the key
 * A copy of the Perseids SSH key (`perseidskey.pem`). This should be in the parent directory of your Puppet checkout.

To check your prerequisites:

1. On your own machine, run:

		$ cd puppet
		$ rake -T
		rake add_check  # Add syntax check hook to your git repo
		rake apply      # Run puppet on ENV['CLIENT'] using branch ENV['BRANCH']
		rake bootstrap  # Bootstrap Puppet on ENV['CLIENT'] using branch ENV['BRANCH']
		rake lint       # Run puppet-lint
		rake lintfix    # Run puppet-lint and fix problems automatically
		rake noop       # Test puppet on ENV['CLIENT'] using branch ENV['BRANCH']

1. Run:

		$ gpg --list-secret-keys 33A6B590
		sec   1024D/0DBB3AFE 2015-11-18
		uid                  Perseids Admin <perseids@tufts.edu>
		ssb   2048g/33A6B590 2015-11-18

### Bootstrapping

1. Run the `rake bootstrap` task from within your Puppet directory, specifying the hostname you want.

    Example:

        rake CLIENT=54.88.205.232 HOSTNAME=monitor bootstrap

    will bootstrap the specified IP as `monitor` and run the `master` Puppet
    branch on it. To use another branch, specify `BRANCH=feature/mybranch`.

1. Enter the secret key passphrase when prompted.

        gpg: about to export an unprotected subkey

        You need a passphrase to unlock the secret key for
        user: "Perseids Admin <perseids@tufts.edu>"
        2048-bit ELG-E key, ID 33A6B590, created 2015-11-18

        Enter passphrase:

1. Enjoy a nice cup of coffee while waiting for the build to complete.

1. Once the first Puppet run has finished, test your connectivity by SSHing to the new server using your personal user account and key:

        $ ssh NEW_SERVER_IP
        Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-74-generic x86_64)
        ...

        john@monitor:~$
