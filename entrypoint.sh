#!/bin/bash

if [ -z "$ETCD_NODE" ]
then
  echo "Missing ETCD_NODE env var"
  exit -1
fi

if [ -z "$HAPROXY_ID" ]
then
  echo "Missing HAPROXY_ID env var"
  exit -1
fi

DNS_SERVERS=$(cat /etc/resolv.conf | grep nameserver | cut -d " " -f2)
echo "Using DNS servers: $DNS_SERVERS"

set -eo pipefail

# Create base dir structure in etcd as confd will complain about missing keys that are watched
echo "Creating base structure for etcd..."
curl -sL $ETCD_NODE/v2/keys/haproxy-$HAPROXY_ID/services -XPUT -d dir=true
curl -sL $ETCD_NODE/v2/keys/haproxy-$HAPROXY_ID/tcp-services -XPUT -d dir=true
curl -sL $ETCD_NODE/v2/keys/haproxy-$HAPROXY_ID/certs -XPUT -d dir=true
echo "..done"

echo "[haproxy-confd] booting HAProxy $HAPROXY_ID. Reading configuration from ETCD: $ETCD_NODE"
DNS_SERVERS=$DNS_SERVERS confd -backend="etcd" -prefix="/haproxy-$HAPROXY_ID" -node "$ETCD_NODE" -interval=$BACKEND_POLLING_INTERVAL "$@"
