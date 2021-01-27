docker-swift
============

[![Docker Pulls](https://img.shields.io/docker/pulls/bouncestorage/swift-aio.svg)](https://hub.docker.com/r/bouncestorage/swift-aio/)
[![](https://images.microbadger.com/badges/image/bouncestorage/swift-aio.svg)](https://microbadger.com/images/bouncestorage/swift-aio)

Docker image for Swift all-in-one demo deployment

This is an attempt to dockerize the instructions for a [Swift All-in-one deployment](https://docs.openstack.org/swift/latest/development_saio.html).

Swift requires xattr to be enabled. With the overlay2 storage driver, Docker
supports extended attributes. However, if you're using the older AUFS storage
driver, it isn't possible for Swift to use storage within the Docker image.
The workaround for this is to mount a volume from a filesystem where xattr is
enabled (e.g. ext4 or xfs).

If you'd like the data to be persistent, you should also store it in an external
volume.

## This works:

This uses Docker's storage:
```
docker build -t bouncestorage/swift-aio .
docker run -P -t bouncestorage/swift-aio
curl -v -H 'X-Storage-User: test:tester' -H 'X-Storage-Pass: testing' http://127.0.0.1:<port>/auth/v1.0
curl -v -H 'X-Auth-Token: <token-from-x-auth-token-above>' <url-from-x-storage-url-above>
swift -A http://127.0.0.1:<port>/auth/v1.0 -U test:tester -K testing stat
```

To persist data, you can replace the `docker run` command with the following:
```
docker run -P -v /path/to/data:/swift/nodes -t bouncestorage/swift-aio
```

Discover the port by running `docker ps`, which will give output like this:

```
ID                  IMAGE                          COMMAND               CREATED             STATUS              PORTS
159caa6f384b        bouncestorage/swift-aio:latest /bin/bash /swift/bin   9 minutes ago       Up 9 minutes        49175->22, 49176->8080
```

You want the port that is mapped to port 8080 within the Docker image, in this case 49176.

Get an authorization token like this:

```
curl -v -H 'X-Storage-User: test:tester' -H 'X-Storage-Pass: testing' http://127.0.0.1:<port>/auth/v1.0
```

Result:

```
* About to connect() to 127.0.0.1 port 8080 (#0)
*   Trying 127.0.0.1... connected
> GET /auth/v1.0 HTTP/1.1
> User-Agent: curl/7.22.0 (x86_64-pc-linux-gnu) libcurl/7.22.0 OpenSSL/1.0.1 zlib/1.2.3.4 libidn/1.23 librtmp/2.3
> Host: 127.0.0.1:8080
> Accept: */*
> X-Storage-User: test:tester
> X-Storage-Pass: testing
>
< HTTP/1.1 200 OK
< X-Storage-Url: http://127.0.0.1:8080/v1/AUTH_test
< X-Auth-Token: AUTH_tk246b80e9b72a42e68a76e0ff2aaaf051
< Content-Type: text/html; charset=UTF-8
< X-Storage-Token: AUTH_tk246b80e9b72a42e68a76e0ff2aaaf051
< Content-Length: 0
< Date: Mon, 28 Oct 2013 22:48:51 GMT
<
* Connection #0 to host 127.0.0.1 left intact
* Closing connection #0
```

To run the demo.sh script, store the X-Storage-Url and X-Auth-Token values in environment variables:

```
export URL=http://127.0.0.1:8080/v1/AUTH_test
export TOKEN=AUTH_tk246b80e9b72a42e68a76e0ff2aaaf051
```

You can then run demo.sh, which will execute a series of curl commands to create
a container, list various information, put itself into Swift as object
"testcontainer/testobject", and retrieve itself again as "retrieved_demo.sh".

## Notes

Uses [supervisord](http://supervisord.org/) to keep the image running. To get a shell on the container, you can use:

```
docker exec -it <container name> /bin/bash
```

Tail /var/log/syslog to see what it's doing.

## Notes on changes from Swift-AIO instructions

- user and group ids are swift:swift
- the instructions provide for using a separate partition or a loopback for
  storage, presumably to allow the storage capacity to be strictly limted.
  Neither of these was easy for a Docker n00b to implement, so I've just used
  /swift, with symbolic links in /srv. The storage can be limited at the OS
  level in the Docker image if it's a concern.
- the Github sources are cloned to /usr/local/src

## License

Copyright (C) 2020 NVIDIA

Copyright (C) 2019-2020 SwiftStack

Copyright (C) 2015-2019 Bounce Storage

Copyright (C) 2013-2015 Peter Binkley @pbinkley

Licensed under the Apache License, Version 2.0
