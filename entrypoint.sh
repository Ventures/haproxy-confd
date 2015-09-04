#!/bin/bash

if [ -z "$ETCD_NODE" ]
then
  echo "Missing ETCD_NODE env var"
  exit -1
fi

set -eo pipefail

#confd will start haproxy, since conf will be different than existing (which is null)

echo "[haproxy-confd] booting HAProxy $HAPROXY_ID. Reading configuration from ETCD: $ETCD_NODE"
confd -backend="etcd" -prefix="/haproxy-$HAPROXY_ID" -node "$ETCD_NODE"
