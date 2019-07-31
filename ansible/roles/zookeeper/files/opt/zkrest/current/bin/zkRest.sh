#!/usr/bin/env bash

set -euo pipefail

cd /opt/zkrest/current
java -cp $(ls zookeeper-*.jar lib/*.jar | xargs | tr ' ' :):/opt/app/conf/zkrest \
    -Xmx90m org.apache.zookeeper.server.jersey.RestMain