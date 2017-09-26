#!/bin/bash
LOCKFILE=/var/tmp/puppet.lock
export PATH=/usr/bin:/usr/local/bin:/opt/puppetlabs/bin:${PATH}
if [ "$1" != "--now" ]; then
  ruby -e 'sleep rand(540)'
fi

if [ -e ${LOCKFILE} ]; then
  REASON=`cat ${LOCKFILE}`
  if [ "${REASON}" == "" ]; then
    REASON='none'
  fi
  echo "Won't run.  Puppet is locked.  Reason: ${REASON}"
  exit 1
else
  trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
  cd /etc/puppetlabs/code/environments/production && timeout 180 git pull
  plock run-puppet
  papply --color false
  rm ${LOCKFILE}
  trap - INT TERM EXIT
fi
