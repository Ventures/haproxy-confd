HAProxy combined with confd for HTTP load balancing with automatic service discovery and reconfiguration throuh etcd.

## Pre-requisites

This setup depends on finding the service backends through DNS. If you are using Docker to run your services we highly suggest to use some orchestration layer such as Kontena. At least consider using for example weave to network your containers and to give them addressable DNS entries.

## Features

* HAProxy 1.5.x backed by Confd 0.10.0
  * ConfD from jnummelin/confd fork for time being since that supports dynamic backend DNS discovery and has pre-build package for Alpine Linux
* Uses zero-downtime reconfiguration (e.g - instead of harpy reload, which will drop all connections, will gradually transfer new connections to the new config)
* Added validation for existence of keys in backing kv store, to prevent failures
* Supports certificates from etcd as well
  * For time being the certs are not encrypted so make sure the access to your etcd is secure in other ways.

## Configuration through etcd

Create the paths allowing confd to find the services:
```bash
etcdctl mkdir "/haproxy-<haproxy_id>/services"
etcdctl mkdir "/haproxy-<haproxy_id>/tcp-services"
```

### Basic configuration

Depending on your needs, create one or more services or tcp-services.
For instance, to create an http service named *myapp* linked to the domain *example.org*.
```bash
etcdctl set "/haproxy-<haproxy_id>/services/myapp/domain" "example.org"
etcdctl set "/haproxy-<haproxy_id>/services/myapp/port" "80"
```

The dynamic backend resolving expects to find your backend IPs from DNS using the given service name.

### Backend selection through URL matching

Currently this HAProxy setup supports URL beginning matching (url_beg). This can be very handy e.g. in cases where HAProxy is used as API proxy. In this case you can route requests for same domain but for different paths to different backends:
```
http://domain/api_A
http://domain/api_B
```
To achieve this setup following config on etcd:
```bash
etcdctl set "/haproxy-<haproxy_id>/services/myapi/url_beg" "/api_A"
etcdctl set "/haproxy-<haproxy_id>/services/myapi/port" "80"
tcdctl set "/haproxy-<haproxy_id>/services/otherapi/url_beg" "/api_B"
etcdctl set "/haproxy-<haproxy_id>/services/otherapi/port" "80"
```


# Creating the proxy

Create and start the service making sure to expose port 80 and 443 on the host machine and open them in your firewall.

**REMEMBER to set the environment variable *HAPROXY-ID* so that each proxy service will read correct configuration from etcd.**

```bash
docker run -d -e HAPROXY-ID=haproxy-1 -p 80:80 -p 443:443 -e ETCD_NODE=<DNS/IP of your etcd> confd-haproxy:latest
```

If you scale your app or the app containers change, built in DNS resolving will automatically update the backend addresses.

To *remove a service*, and so a directory, you must type
```bash
etcdctl rmdir "/haproxy-<haproxy_id>/services/myapp"
```

## TCP services

TCP Service proxying is also supported and the overall mechanism is the same as with HTTP services. For TCP services you need to configure both external and internal ports via etcd:
```bash
etcdctl set "/haproxy-<haproxy_id>/tcp-services/galera/external_port" "3306"
etcdctl set "/haproxy-<haproxy_id>/tcp-services/galera/internal_port" "3306"

```

The above will tell HAProxy to listen to conections in port 3306 and direct traffic to backends found via DNS discovery using name *galera*

## Building the image

The image is based on Alpine Linux image provided by Gliderlabs. Alpine is used since it's really minimal in size yet it provides all necessary building blocks.

```
docker build -t your_repo/haproxy-confd:<version> .
```

Have fun !
