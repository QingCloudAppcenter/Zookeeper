#!/usr/bin/env bash

data=`echo srvr | nc -q 2 127.0.0.1 2181`
mode=`echo "$data" | awk -F': ' '$1 == "Mode" {print toupper(substr($2, 0, 1))}'`
latency=`echo "$data" | awk -F': ' '$1 == "Latency min/avg/max" {print $2}'`
min=`echo "$latency" | awk -F'/' '{print $1}'`
avg=`echo "$latency" | awk -F'/' '{print $2}'`
max=`echo "$latency" | awk -F'/' '{print $3}'`
received=`echo "$data" | awk -F': ' '$1 == "Received" {print $2}'`
sent=`echo "$data" | awk -F': ' '$1 == "Sent" {print $2}'`
active=`echo "$data" | awk -F': ' '$1 == "Connections" {print $2}'`
outstanding=`echo "$data" | awk -F': ' '$1 == "Outstanding" {print $2}'`
znode=`echo "$data" | awk -F': ' '$1 == "Node count" {print $2}'`

cat <<EOF
{"mode":"$mode","min":$min,"avg":$avg,"max":$max,"received":$received,"sent":$sent,"active":$active,"outstanding":$outstanding,"znode":$znode}
EOF
