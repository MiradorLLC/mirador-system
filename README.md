## Local SSL Dev Proxy
**Current Support** OSX only
### **TL;DR**

 Run setup script
    * `./setup.sh`

#### Requirements
* Docker 17.06 or any other Docker v17.x

#### Local Dev Proxy Components
* setup.sh - orchestrates all components for localhost proxy
    * Creates mDNS resolver for osx
    * creates SANs certs for domains (wildcard cert)
    * Adds certs to OSX Keychain as TrustAlways (removes browser issues)
    * Starts both dnsmasq and nginx docker containers
* DNSMasq - local DNS resolution
    * removes need for configuring hosts file
    * sets up mDNS osx resolver `/etc/resolver/makemydeal.dev`
    * configures requests to DNS to forward to localhost
    * Runs a webserver on http://127.0.0.1:5380 to view DNS requests
* NGINX - proxy server
    * consumes certs created by setup script
    * proxies from servername to localhost port

### General Notes
Recently, a number of the media sites have begun serving their sites over SSL.  Along with our desire to perform more development of our client apps against live sites, this caused an issue for local development in that you cannot load non-ssl iframes on an ssl hosted page.

In an effort to keep our apps locally running similar to the hosted environments, a local nginx proxy enables us to serve the app with a localhost domain (*.makemydeal.dev)

We include a localhost DNS server to resolve all `*.loca.lt` domains and then a nginx proxy to take the server name (e.g. `miradorllc.loca.lt`) and proxy it to the correct localhost port.  Exactly similar to our AWS environment setup

#### Useful commands
* `docker ps` - identify containers running
* `docker logs osx_nginx_1` - displays logs for the nginx container
* `docker kill -s HUP osx_nginx_1` - restarts nginx server in nginx container if proxy.conf changes have been made

#### Important dependency consideration:
> Know that the containers requires to have free the host's ports: 80, 443, 53535, 5380.

- Common error message related with this kind of problem:

```bash
Starting osx_nginx_1 ...
Starting osx_nginx_1 ... error

ERROR: for osx_nginx_1  Cannot start service nginx: driver failed programming external connectivity on endpoint osx_nginx_1 (143c6a54262ab3cbf52dddae2641390c39974dc9c95eadd6b883e5e5d052ebd2): Error starting userland proxy: Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)

ERROR: for nginx  Cannot start service nginx: driver failed programming external connectivity on endpoint osx_nginx_1 (143c6a54262ab3cbf52dddae2641390c39974dc9c95eadd6b883e5e5d052ebd2): Error starting userland proxy: Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)
ERROR: Encountered errors while bringing up the project.
```

> Key message: `(Failure EADDRINUSE)`

- Solution:
    - Look for the process which is using the needed port:

        `$ sudo lsof -n -i :80 | grep LISTEN`

        output :

        `vpnkit  32904 rrodrguezp   22u  IPv4 0x253b0c4f68950649      0t0  TCP *:http (LISTEN)`

        > 32904 is the pid id for this process and it can be use to kill it closing the used port as result of the operation.

    - After detected which program is using the port and stopped it, re-run the setup to start the containers.
