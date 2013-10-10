# DOCKER-VERSION 0.6.4
FROM   ubuntu:12.04

RUN	echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list

RUN	apt-get update
RUN	apt-get install -y curl gcc memcached rsync sqlite3 xfsprogs git-core libffi-dev python-setuptools sudo
RUN	apt-get install -y python-coverage python-dev python-nose python-simplejson python-xattr python-eventlet python-greenlet python-pastedeploy python-netifaces python-pip python-dnspython python-mock

# create swift user and group
RUN	/usr/sbin/useradd -m -d /swift -U swift

#RUN	truncate -s 1GB /srv/swift-disk
#RUN	mkfs.xfs /srv/swift-disk
#RUN	echo "/srv/swift-disk /mnt/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab

#RUN	mkdir /mnt/sdb1

#RUN	mount /mnt/sdb1
RUN	mkdir /swift/1 /swift/2 /swift/3 /swift/4

RUN	chown swift:swift /swift/*

RUN	for x in {1..4}; do ln -s /swift/$x /srv/$x; done

RUN	mkdir -p /etc/swift/object-server /etc/swift/container-server /etc/swift/account-server /srv/1/node/sdb1 /srv/2/node/sdb2 /srv/3/node/sdb3 /srv/4/node/sdb4 /var/run/swift

RUN	chown -R swift:swift /etc/swift /srv/[1-4]/ /var/run/swift  

# Setting up rsync

ADD ./rsyncd.conf /etc/
RUN	sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync
RUN	grep RSYNC_ENABLE /etc/default/rsync
RUN	service rsync start

ADD ./swift /etc/

RUN	cd /usr/local/src; git clone https://github.com/openstack/python-swiftclient.git
RUN	cd /usr/local/src; git clone https://github.com/openstack/swift.git
RUN	ls -l /usr/local/src

RUN	cd /usr/local/src/python-swiftclient; python setup.py develop; cd -
RUN	cd /usr/local/src/swift; python setup.py develop; cd -
RUN	pip install -r /usr/local/src/swift/test-requirements.txt

ADD ./bin /home/swift/
RUN	ls -l /home/swift
RUN	ls -l /home/swift/bin
RUN	chmod +x /home/swift/bin/*

RUN	ls -l /home/swift/bin
#EXPOSE  8080
#CMD ["node", "/src/index.js"]
