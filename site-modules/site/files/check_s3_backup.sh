#!/bin/bash

TODAY=`date +%Y%m%d`
S3_BACKUPDIR=$1

if /usr/bin/s3cmd ls ${S3_BACKUPDIR} |grep ${TODAY};
then
  echo OK: backup for ${TODAY} is present on S3
else
  echo Error: backup for ${TODAY} not found
fi
