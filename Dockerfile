# DOCKER-VERSION 0.6.4
FROM   ubuntu:12.04

RUN	echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list

RUN	apt-get update
RUN	apt-get upgrade -y

RUN	apt-get install -y curl gcc memcached rsync sqlite3 xfsprogs git-core libffi-dev python-setuptools sudo
RUN	apt-get install -y python-coverage python-dev python-nose python-simplejson python-xattr python-eventlet python-greenlet python-pastedeploy python-netifaces python-pip python-dnspython python-mock

# create swift user and group
RUN	/usr/sbin/useradd -m -d /swift -U swift

# set up storage
RUN	mkdir -p /swift/nodes/1 /swift/nodes/2 /swift/nodes/3 /swift/nodes/4

RUN	for x in {1..4}; do ln -s /swift/nodes/$x /srv/$x; done

RUN	mkdir -p /srv/1/node/sdb1 /srv/2/node/sdb2 /srv/3/node/sdb3 /srv/4/node/sdb4 /var/run/swift
ADD	./swift /etc/swift

RUN	chown -R swift:swift /swift/* /etc/swift /srv/[1-4]/ /var/run/swift  

# Setting up rsync

ADD ./misc/rsyncd.conf /etc/
RUN	sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

RUN	cd /usr/local/src; git clone https://github.com/openstack/python-swiftclient.git
RUN	cd /usr/local/src; git clone https://github.com/openstack/swift.git

RUN	cd /usr/local/src/python-swiftclient; python setup.py develop; cd -
RUN	cd /usr/local/src/swift; python setup.py develop; cd -
RUN	pip install -r /usr/local/src/swift/test-requirements.txt

ADD ./bin /swift/bin
RUN	chmod +x /swift/bin/*

ADD	./misc/bashrc /swift/.bashrc
RUN	chmod u+x /swift/.bashrc; /swift/.bashrc

RUN	cp /usr/local/src/swift/test/sample.conf /etc/swift/test.conf

# unittests currently produce one failure
#RUN	/usr/local/src/swift/.unittests

RUN	easy_install supervisor
RUN	mkdir /var/log/supervisor/
ADD     ./misc/supervisord.conf /etc/supervisord.conf

RUN	apt-get install -y openssh-server openssh-client
RUN	mkdir /var/run/sshd
RUN	echo swift:fingertips | chpasswd

#RUN	sudo -u swift /swift/bin/startmain
#RUN	sudo -u swift curl -v -H 'X-Storage-User: test:tester' -H 'X-Storage-Pass: testing' http://127.0.0.1:8080/auth/v1.0

EXPOSE 8080
EXPOSE 22
CMD ["/bin/bash", "/swift/bin/launch.sh"]

