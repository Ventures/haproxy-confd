FROM gliderlabs/alpine:3.2

MAINTAINER jussi.nummelin@digia.com

# Default to grid internal etcd
ENV ETCD_NODE etcd.kontena.local:2379
ENV confd_ver 0.10.0
ENV CERT_SPLIT_TOKEN %_%_%_%_%_%_%_%_%_%_%_%_%

# Install needed packages
RUN apk update && apk --update add ca-certificates \
    libssl1.0 openssl bash haproxy coreutils && \
    mkdir -p /etc/haproxy/certs/

# Install confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v${confd_ver}/confd-${confd_ver}-linux-amd64 -O /bin/confd && \
	chmod +x /bin/confd

ADD confd /etc/confd


# Expose ports.
EXPOSE 80

ADD entrypoint.sh /entrypoint.sh
ADD cert_splitter.sh /bin/cert_splitter.sh
RUN chmod +x /bin/cert_splitter.sh
ENTRYPOINT ["/entrypoint.sh"]
