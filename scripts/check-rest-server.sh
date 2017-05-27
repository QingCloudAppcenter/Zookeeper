#!/bin/bash
        
ZOOKEEPER_BIN_PATH="/opt/zookeeper/bin"
ZOOKEEPER_PID_FILE="/data/zookeeper/rest_server.pid"

"$ZOOKEEPER_BIN_PATH"/zkServer.sh status
if [ $? -ne 0 ]
then
  exit 1 # zk server is not running
else
  curl http://localhost:9998  
  if [ $? -ne 0 ] # zk rest server is not running
  then
    if [ -f $ZOOKEEPER_PID_FILE ] # zk pid file exists
    then
      rm $ZOOKEEPER_PID_FILE
    fi  
    "$ZOOKEEPER_BIN_PATH"/rest.sh start
  fi
fi

exit 0
