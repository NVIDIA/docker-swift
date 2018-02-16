# DOCKER-VERSION 0.6.4
FROM	ubuntu:14.04

RUN	echo "deb http://archive.ubuntu.com/ubuntu trusty-backports universe" >> /etc/apt/sources.list

# workaround for Ubuntu dependency on upstart https://github.com/dotcloud/docker/issues/1024
RUN	dpkg-divert --local --rename --add /sbin/initctl; ln -sf /bin/true /sbin/initctl

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-utils \
        attr \
        gcc \
        git-core \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        memcached \
        net-tools \
        python-coverage \
        python-dev \
        python-dnspython \
        python-eventlet \
        python-greenlet \
        python-lxml \
        python-mock \
        python-netifaces \
        python-nose \
        python-pastedeploy \
        python-pip \
        python-setuptools \
        python-simplejson \
        python-xattr \
        rsyslog \
        rsync \
        sqlite3 \
        sudo \
        xfsprogs && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD http://mirrors.kernel.org/ubuntu/pool/main/libe/liberasurecode/liberasurecode1_1.4.0-2_amd64.deb \
    http://mirrors.kernel.org/ubuntu/pool/main/libe/liberasurecode/liberasurecode-dev_1.4.0-2_amd64.deb \
    /
RUN	dpkg -i liberasurecode-dev_1.4.0-2_amd64.deb \
            liberasurecode1_1.4.0-2_amd64.deb \
    && rm liberasurecode-dev_1.4.0-2_amd64.deb liberasurecode1_1.4.0-2_amd64.deb

RUN pip install --upgrade \
    pip \
    setuptools

# work around a missing dependency
RUN	pip install pytz

RUN git clone --branch 3.3.0 --single-branch --depth 1 https://github.com/openstack/python-swiftclient.git /usr/local/src/python-swiftclient && \
    cd /usr/local/src/python-swiftclient && \
    python setup.py develop && \
    cd -
RUN git clone --branch 2.15.1 --single-branch --depth 1 https://github.com/openstack/swift.git /usr/local/src/swift && \
    cd /usr/local/src/swift && \
    python setup.py develop && \
    cd -
RUN git clone --branch 1.11 --single-branch --depth 1 https://github.com/openstack/swift3.git /usr/local/src/swift3 && \
    cd /usr/local/src/swift3 && \
    python setup.py develop && \
    cd -

RUN	pip install -r /usr/local/src/swift/test-requirements.txt

RUN	easy_install supervisor; mkdir /var/log/supervisor/

# create swift user and group
RUN	/usr/sbin/useradd -m -d /swift -U swift


COPY ./swift /etc/swift

# Setting up rsync

COPY ./misc/rsyncd.conf /etc/
RUN	sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

RUN     sed -i 's/SLEEP_BETWEEN_AUDITS = 30/SLEEP_BETWEEN_AUDITS = 86400/' /usr/local/src/swift/swift/obj/auditor.py

COPY ./bin /swift/bin
RUN	chmod +x /swift/bin/*

COPY ./misc/bashrc /swift/.bashrc

RUN	cp /usr/local/src/swift/test/sample.conf /etc/swift/test.conf

COPY ./rsyslog.d/10-swift.conf /etc/rsyslog.d/10-swift.conf
RUN	sed -i 's/\$PrivDropToGroup syslog/\$PrivDropToGroup adm/' /etc/rsyslog.conf
RUN	mkdir -p /var/log/swift/hourly; chown -R syslog.adm /var/log/swift; chmod -R g+w /var/log/swift

COPY ./misc/supervisord.conf /etc/supervisord.conf

RUN	echo swift:fingertips | chpasswd; usermod -a -G sudo swift

RUN echo %sudo	ALL=NOPASSWD: ALL >> /etc/sudoers

VOLUME	/swift/nodes

EXPOSE 8080
CMD ["/bin/bash", "/swift/bin/launch.sh"]
