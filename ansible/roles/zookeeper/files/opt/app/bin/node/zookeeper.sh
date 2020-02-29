EC_RETRIEVE_MODE_ERR=210
EC_SCLIN_NOT_FOLLOWER=211
EC_NO_LEADER_FOUND=212
EC_START_ERR=213
EC_UNKNOWN_ZK_ID=214
EC_DELETING_TOO_MANY=215
EC_UNKNOWN_MODE=216
EC_MEASURE_ERR=220

initNode() {
  mkdir -p /data/zookeeper/{dump,logs} /data/zkrest
  chown -R zookeeper.svc /data/{zookeeper,zkrest}
  local htmlFile=/data/index.html; [ -e "$htmlFile" ] || ln -s /opt/app/conf/caddy/index.html $htmlFile
  _initNode
}

start() {
  isNodeInitialized || initNode
  reconfigure

  # Make sure newly joined nodes start after previously nodes to avoid data loss
  if [[ "$JOINING_NODES " == *"/$MY_IP "* ]]; then
    local node; for node in $STABLE_NODES; do retry 5 1 0 checkEndpoint tcp:2181 ${node##*/}; done
  fi

  _start

  if [[ "$JOINING_NODES " == *"/$MY_IP "* ]]; then retry 3600 1 0 checkFullyStarted; fi
  if [ "$IS_UPGRADING" == "true" ]; then retry 450 1 0 checkFullyStarted; fi
}

reconfigure() {
  [ -n "$MY_ZK_ID" ] && echo $MY_ZK_ID > /data/zookeeper/myid || return $EC_UNKNOWN_ZK_ID
}

checkFullyStarted() {
  local ip=${1:-$MY_IP} mode=${2:-"(leader|follower|standalone)"}
  retrieveMode $ip | egrep -q "^$mode$" || return $EC_START_ERR
}

retrieveMode() {
  local ip=${1:-$MY_IP}
  echo mntr | nc -q2 -w2 $ip 2181 | egrep "^zk_server_state\s(leader|follower|standalone)$" | cut -f2 || {
    log "ERROR Failed to retrieve mode of $ip."
    return $EC_RETRIEVE_MODE_ERR
  }
}

reload() {
  if ! isNodeInitialized; then return 0; fi

  if [ "$1" == "zookeeper" ]; then
    if [ -n "$LEAVING_NODES" ]; then return 0; fi
    reconfigure
  fi

  _reload $@
}

destroy() {
  if [[ "$LEAVING_NODES " == *"/$MY_IP "* ]]; then
    local mode; mode=$(retrieveMode)
    [ "$mode" == "follower" ] || {
      log "The current mode is '$mode' instead of 'follower'."
      return $EC_SCLIN_NOT_FOLLOWER
    }
  fi
}

findNodeIdOfLeader() {
  local nodesCount="$(echo $STABLE_NODES | wc -w)"
  local node; for node in $STABLE_NODES; do
    local ip=${node##*/} mode; mode="$(retrieveMode $ip)"
    if [ "$mode" == "leader" ] || [ "$mode" = "standalone" -a "$nodesCount" -eq 1 ]; then
      echo $node | cut -d/ -f2
      return 0
    fi
  done

  log "ERROR Failed to find leader node among all nodes ($STABLE_NODES)."
  return $EC_NO_LEADER_FOUND
}

backup() {
  log "Taking snapshot ..."
}

restore() {
  find /data -mindepth 1 -maxdepth 1 ! -name zookeeper -exec rm -rf {} \;
  find /data/zookeeper -mindepth 1 -maxdepth 1 ! -name version-2 -exec rm -rf {} \;
  start
}

checkSvc() {
  if [ "$1" == "zookeeper" ]; then
    retrieveMode | egrep -q '^(leader|follower|standalone)$' || return $EC_UNKNOWN_MODE
  fi
  _checkSvc $@
}

measure() {
  local mappings="
  zk_server_state/mode
  zk_([^_]*)_latency/\\1
  zk_packets_/
  zk_num_alive_connections/active
  zk_(outstanding)_requests/\\1
  zk_(znode)_count/\\1
  "
  echo mntr | nc -q2 -w2 localhost 2181 \
    | grep -v "This ZooKeeper instance is not currently serving requests" \
    | sed -r "$(echo "$mappings" | grep '\S' | sed 's#^ *#s/#g; s#$#/g;#g' | paste -s)" \
    | awk '$1=="mode"{$2=toupper(substr($2, 0, 1))} {print $1, $2}' \
    | jq -R 'split(" ") | {(.[0]): .[1]}' | jq -sc add \
    || (log "ERROR Failed to measure zk ($?)." && return $EC_MEASURE_ERR)
}
