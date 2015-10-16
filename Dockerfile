FROM gliderlabs/alpine:3.2

MAINTAINER jussi.nummelin@digia.com

# Default to grid internal etcd
ENV ETCD_NODE http://etcd.kontena.local:2379
ENV confd_ver 0.10.0
ENV CERT_SPLIT_TOKEN ====================
ENV BACKEND_POLLING_INTERVAL 10

# Install needed packages
RUN apk update && apk --update add ca-certificates \
    libssl1.0 openssl bash coreutils curl pcre  && \
    mkdir -p /etc/haproxy/certs/

# Install HAProxy 1.6
RUN apk --update add --virtual build-dependencies build-base linux-headers pcre-dev openssl-dev && \
  wget http://www.haproxy.org/download/1.6/src/haproxy-1.6.0.tar.gz && \
  tar zxvf haproxy-1.6.0.tar.gz && cd haproxy-1.6.0 && \
  make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_CRYPT_H=1 USE_LIBCRYPT=1 && \
  make install-bin && cd .. && \
  rm -rf haproxy-1.6.0* && \
  apk del build-dependencies

RUN adduser -D haproxy

# Install confd
RUN wget https://github.com/jnummelin/confd/releases/download/v0.11.0/confd_alpine -O /bin/confd && \
	chmod +x /bin/confd

ADD confd /etc/confd

# Expose ports.
EXPOSE 80
EXPOSE 443

ADD entrypoint.sh /entrypoint.sh
ADD cert_splitter.sh /bin/cert_splitter.sh
RUN chmod +x /bin/cert_splitter.sh
ENTRYPOINT ["/entrypoint.sh"]
