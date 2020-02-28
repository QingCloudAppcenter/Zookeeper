#!/usr/bin/env bash

source "$(dirname $0)"/common.sh

function appStart() {
  zkRestStop
  zkStop
  zkStart
  zkRestStart
}

function appStop() {
  zkRestStop
  zkStop
}

function appRestart() {
  # If common.sh is initialized by confd before zoo.cfg, then we just wait for another trigger when zoo.cfg is set up.
  if [ -f /opt/zkapp/conf/server/zoo.cfg ]; then
    zkRestStop
    zkStop
    zkStart
    zkRestStart
  fi
}

case $1 in
start)
  echo "Starting ZooKeeper app..."
  appStart
  echo "Started."
  ;;
stop)
  echo "Stopping ZooKeeper app..."
  appStop
  echo "Stopped."
  ;;
restart)
  echo "Restarting ZooKeeper app..."
  appRestart
  echo "Restarted."
  ;;
*)
  echo "Usage: $0 {start|stop|restart}" >&2

esac

