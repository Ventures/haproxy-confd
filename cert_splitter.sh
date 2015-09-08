#!/bin/sh
echo "Splitting bundled certificates..."
cd /tmp
csplit -s -f cert -b %02d_gen.pem certs.pem "/$CERT_SPLIT_TOKEN/+1"
rm /etc/haproxy/certs/cert*_gen.pem
mv cert*_gen.pem /etc/haproxy/certs/
etcdctl set --peers $ETCD_NODE /haproxy-$HAPROXY_ID/certs true
echo "...done. New certificates updated into HAProxy."
