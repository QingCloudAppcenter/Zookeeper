#!/bin/bash
        
ZOOKEEPER_DATA_PATH="/data/zookeeper"
ZOOKEEPER_BIN_PATH="/opt/zookeeper/bin"
count=$(ls -l $ZOOKEEPER_DATA_PATH/version-2/snapshot* | wc -l)
if [ $count -gt 3 ]; then
  $ZOOKEEPER_BIN_PATH/zkCleanup.sh -n 3
fi

exit 0
