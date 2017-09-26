#!/bin/bash
BUFFER=/tmp/arethusa
DESTINATION=$1
if [ $DESTINATION == ""]
then
  echo Usage: $0 DESTINATION
  echo Deploy to DESTINATION directory
  exit 1
fi
rm -rf ${BUFFER}
rsync -Pa app bower_components docs dist vendor favicon.ico ${BUFFER}
rm -rf ${DESTINATION}.prev
mkdir -p ${DESTINATION}
mv ${DESTINATION}/ ${DESTINATION}.prev
mv ${BUFFER}/ ${DESTINATION}/
