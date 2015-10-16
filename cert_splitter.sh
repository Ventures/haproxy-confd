#!/bin/sh
echo "Splitting bundled certificates..."
cd /tmp
sed '/^$/d' certs.pem > certs_tmp.pem && csplit --elide-empty-files -s -f cert -b %02d_gen.pem certs_tmp.pem "/-----END .* PRIVATE KEY-----/+1"
rm /etc/haproxy/certs/cert*_gen.pem
mv cert*_gen.pem /etc/haproxy/certs/
if [ -f cert00_gen.pem ];
then
  curl -L -X PUT http://$ETCD_NODE/v2/keys/haproxy-$HAPROXY_ID/certs -d value=true
else
  curl -L -X PUT http://$ETCD_NODE/v2/keys/haproxy-$HAPROXY_ID/certs -d dir=true
fi
rm cert*_gen.pem
echo "...done. New certificates updated into HAProxy."
