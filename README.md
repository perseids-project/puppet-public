# Perseids Puppet Repository

The Perseids Puppet Repository contains manifests for:

* installing and deploying all Perseids' services on AWS EC2 instances (Ubuntu 14.04 and 16.04)
* setting up a development environment for Perseids' core services on a Vagrant box

1. Start with the [Node Overview](doc/NodeOverview.md)

2. Review the [Node Data Dependencies](doc/NodeDataDependencies.md)

3. See the [Deploying Releases](doc/DeployingReleases.md)

4. See also [things that aren't puppetized](doc/Exceptions.md)

See also instructions for:

* [Seting up a new AWS Infrastructure](doc/Set%20up%20a%20new%20AWS%20infrastructure%20for%20Perseids.md)

* [Setting up a Vagrant based development environment](doc/Setup%20a%20Vagrant-Based%20Development%20Environment.md)

* [Restoring data from Duplicity backups](doc/Restore%20data%20from%20Duplicity%20backup.md)
    * And [Finding a deleted file in backups](doc/Find%20a%20deleted%20file%20in%20backups.md)

* [Building a new Puppetized server](doc/Build%20new%20Puppetised%20server.md)

## Puppet Management

The Perseids nodes are all configured to have the puppet manifests installed as a clone from this GitHub master repository at `/etc/puppetlabs/code/environments/production`

The `run-puppet` script is configured as a root cron job to run every 10 minutes. It creates/checks a lock file and then calls the `papply` script which pulls the latest puppet code from the the master branch of this GitHub repo, uses R10K to install the 3rd party modules specified in the  [Puppetfile](https://github.com/perseids-project/perseids-puppet/blob/master/Puppetfile), and then applies the local manifests.

## Hiera

The [hiera.yaml](https://github.com/perseids-project/perseids-puppet/blob/master/hiera.yaml) defines the files which contain
the hiera configuration settings for the puppet manifests and the order in which they are applied.

The majority of the settings can be found in [common.yaml](https://github.com/perseids-project/perseids-puppet/blob/master/data/common.yaml). The AWS config is in [aws.yaml](https://github.com/perseids-project/perseids-puppet/blob/master/data/aws.yaml).

Sensitive information is encrypted in [secret.eyaml](https://github.com/perseids-project/perseids-puppet/blob/master/data/common.yaml).  To edit this file you must have [heira-eyaml](https://puppet.com/blog/encrypt-your-data-using-hiera-eyaml) and the Perseids GPG key installed.  The easiest way to do this is from one the puppetized instances, 
using the [eyaml_edit](https://github.com/perseids-project/perseids-puppet/blob/master/tools/eyaml_edit) script:

```
sudo su - 
cd /etc/pupptelabs/code/environments/production
sudo tools/eyaml_edit data/secret.eyaml
```

## Vim environment

When editing with Vim on Puppetized servers, the following extra features are available:

* CtrlP file finder (press `Ctrl-P`)
* Nerdtree file browser/manager (press `Ctrl-N`)
* Ack full text search (press `comma-A` and enter a search string)

Other handy things to know:

* In insert mode, pressing `Ctrl-N` autocompletes the current word, based on open buffers
* When entering Puppet attributes, typing `=>` auto-aligns the current resource
* Create a vertical split with `:vs` (or press `Ctrl-V` in CtrlP find mode to open in a split)

Vim-diff mode

* With two buffers open, type `:windo diffthis` to enter interactive diff mode
* Vim will highlight all diffs between the two buffers
* Type `]c` to to go to the next diff, or `[c` for previous
* Type `do` ('diff obtain') to get the version from the other buffer
* Type `dp` ('diff put') to push this version to the other buffer
* Type `:diffoff!` to leave diff mode
