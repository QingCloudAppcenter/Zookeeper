#!/usr/bin/env bash

echo srvr | nc -q 2 127.0.0.1 2181 | grep "Mode: "

source "$(dirname $0)"/common.sh
curl http://127.0.0.1:9998 || zkRestRestart
