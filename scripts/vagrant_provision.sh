#!/bin/bash
source /etc/lsb-release
wget http://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
dpkg -i ./puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
apt-key adv --fetch-keys http://apt.puppetlabs.com/DEB-GPG-KEY-puppet
apt-get update
apt-get -y install git puppet-agent build-essential ruby-dev ruby
/opt/puppetlabs/puppet/bin/gem install gpgme --no-rdoc --no-ri
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml-gpg --no-rdoc --no-ri
/opt/puppetlabs/puppet/bin/gem install r10k --no-rdoc --no-ri
mkdir -p /etc/facter/facts.d
echo "perseids_env=development" >/etc/facter/facts.d/perseids_env.txt
cd /etc/puppetlabs/code/environments/production
/opt/puppetlabs/puppet/bin/r10k puppetfile install --verbose
/opt/puppetlabs/bin/puppet apply --environment=production --debug /etc/puppetlabs/code/environments/production/manifests
