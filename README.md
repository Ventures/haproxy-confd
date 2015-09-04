HAProxy combined with confd for HTTP load balancing with automatic service discovery and reconfiguration throuh etcd.

* HAProxy 1.5.x backed by Confd 0.10.0
* Uses zero-downtime reconfiguration (e.g - instead of harpy reload, which will drop all connections, will gradually transfer new connections to the new config)
* Added support for url rexeg (not reggae, damn you spell checker) for routing, in addition to the usual hostname pattern
* Added validation for existence of keys in backing kv store, to prevent failures

## Configuration through etcd

Create the paths allowing confd to find the services:
```bash
etcdctl mkdir "/haproxy-<haproxy_id>/services"
etcdctl mkdir "/haproxy-<haproxy_id>/tcp-services"
```

Depending on your needs, create one or more services or tcp-services.
For instance, to create an http service named *myapp* linked to the domain *example.org*.
```bash
etcdctl set "/haproxy-<haproxy_id>/services/myapp/domain" "example.org"
etcdctl set "/haproxy-<haproxy_id>/services/myapp/port" "80"
```

Based on this Kontena agent will populate automatically the backend IP and port information in following keys:

```
/haproxy-haproxy-1/services/ghost/ghost-1 => 10.81.16.197:80
/haproxy-haproxy-1/services/ghost/ghost-2 => 10.81.10.33:80
```

# Creating the proxy

Create and start the service making sure to expose port 80 on the host machine and open it in your firewall.

**REMEMBER to set the environment variable *HAPROXY-ID* so that each proxy service will read correct configuration from etcd.**

```bash
kontena service create haproxy <repo?>/confd-haproxy:latest -p 80:80 -e HAPROXY-ID=haproxy-1
kontena service deploy haproxy
```

If you scale your app or the app containers change, Kontena agent will automatically update the backend addresses.

To *remove a service*, and so a directory, you must type
```bash
etcdctl rmdir "/haproxy-<haproxy_id>/services/myapp"
```

The commands for a tcp-service are the same but with *tcp-services* instead of *services*


Have fun !
