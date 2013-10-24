docker-swift
============

Docker image for Swift all-in-one demo deployment

This is an attempt to dockerize the instructions for a [Swift All-in-one deployment](http://docs.openstack.org/developer/swift/development_saio.html). 

It is not yet complete.

##This works:

```
docker build -t pbinkley/docker-swift .
docker run -i -t pbinkley/docker-swift /bin/bash
curl -v -H 'X-Storage-User: test:tester' -H 'X-Storage-Pass: testing' http://127.0.0.1:<port>/auth/v1.0
curl -v -H 'X-Auth-Token: <token-from-x-auth-token-above>' <url-from-x-storage-url-above>
swift -A http://127.0.0.1:<port>/auth/v1.0 -U test:tester -K testing stat
```

Uses supervisord to keep the image running. You can ssh in: use sshswift.sh script, give it your password 
when sudo asks for it, then log in as swift with password 'fingertips'.

Tail /var/log/syslog to see what it's doing.

##Notes on changes

- user and group ids are swift:swift
- the instructions provide for using a separate partition or a loopback for storage, presumably to allow the storage capacity to be strictly limted. Neither of these was easy for a Docker n00b to implement, so I've just used /swift, with symbolic links in /srv. The storage can be limited at the OS level in the Docker image if it's a concern.
- the Github sources are cloned to /usr/local/src
