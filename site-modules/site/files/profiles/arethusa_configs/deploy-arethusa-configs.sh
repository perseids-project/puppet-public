#!/bin/bash
BUFFER=/tmp/arethusa_configs
DESTINATION=$1
if [ $DESTINATION == ""]
then
  echo Usage: $0 DESTINATION
  echo Deploy to DESTINATION directory
  exit 1
fi
rm -rf ${BUFFER}
rsync -Pa dist ${BUFFER}
rm -rf ${DESTINATION}.prev
mkdir -p ${DESTINATION}
mv ${DESTINATION}/ ${DESTINATION}.prev
mv ${BUFFER}/ ${DESTINATION}/
