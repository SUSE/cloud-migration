#!/bin/bash

BIN_DIR=$(dirname $(realpath $0))
PARENT_DIR=$(dirname $BIN_DIR)

PID=$(ps -ef | grep -v grep | grep puma | awk '{ print $2 }')
if [ ! -z "$PID" ] ; then
  echo "Killing ${PID}"
  sudo kill -9 $PID
fi
