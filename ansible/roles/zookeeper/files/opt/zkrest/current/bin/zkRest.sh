#!/usr/bin/env bash

set -euo pipefail

cd /opt/zkrest/current
java -cp $(echo zookeeper-*.jar lib/*.jar | tr ' ' :):/opt/app/conf/zkrest \
    -Xmx90m org.apache.zookeeper.server.jersey.RestMain
