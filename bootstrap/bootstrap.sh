#!/bin/bash
PUPPET_REPO="git@github.com:perseids-project/puppet-public.git"
HOSTNAME=$1
BRANCH=$2
PERSEIDS_ENV=$3
hostname ${HOSTNAME}
echo ${HOSTNAME} >/etc/hostname
source /etc/lsb-release
wget http://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
dpkg -i puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb
apt-get update && apt-get -y install git puppet-agent build-essential ruby-dev ruby
/opt/puppetlabs/puppet/bin/gem install gpgme --no-rdoc --no-ri
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml-gpg --no-rdoc --no-ri
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~root/.ssh/config
chmod 600 ~ubuntu/.ssh/id_rsa
cp ~ubuntu/.ssh/id_rsa /root/.ssh/id_rsa
mkdir -p /etc/facter/facts.d
echo "perseids_env=${PERSEIDS_ENV}" >/etc/facter/facts.d/perseids_env.txt
cd /etc/puppetlabs/code/environments
mv production production.orig
git clone ${PUPPET_REPO} production
cd production
git checkout ${BRANCH}
git pull origin ${BRANCH}
touch /var/tmp/puppet.lock
/opt/puppetlabs/puppet/bin/gem install r10k --no-rdoc --no-ri
/opt/puppetlabs/puppet/bin/r10k puppetfile install --verbose
/opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests
rm /var/tmp/puppet.lock
