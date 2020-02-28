#!/usr/bin/env bash

set -e

function exists()
{
  ip link show docker0 >/dev/null 2>&1
}

function remove()
{
  ip link set dev docker0 down
  ip link delete docker0
}

function postDocker()
{
  echo Removing docker0...
  exists && remove
}

case $1 in
post-docker-start)
  echo "Preparing Docker network for ZK app..."
  postDocker
  ;;
*)
  echo "Usage: $0 {post-docker-start}" >&2

esac
