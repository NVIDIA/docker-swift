FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        attr \
        liberasurecode1 \
        memcached \
        python-dnspython \
        python-eventlet \
        python-greenlet \
        python-lxml \
        python-netifaces \
        python-pastedeploy \
        python-pip \
        python-pyeclib \
        python-setuptools \
        python-simplejson \
        python-xattr \
        rsyslog \
        rsync \
        sqlite3 \
        xfsprogs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip setuptools pytz

RUN apt-get update && \
    apt-get install -y --no-install-recommends git-core && \
    git clone --branch 3.8.1 --single-branch --depth 1 https://github.com/openstack/python-swiftclient.git /usr/local/src/python-swiftclient && \
    cd /usr/local/src/python-swiftclient && python setup.py develop && \
    git clone --branch 2.24.0 --single-branch --depth 1 https://github.com/openstack/swift.git /usr/local/src/swift && \
    cd /usr/local/src/swift && python setup.py develop && \
    apt-get remove -y --purge git-core git && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY ./swift /etc/swift
COPY ./misc/rsyncd.conf /etc/
COPY ./bin /swift/bin
COPY ./rsyslog.d/10-swift.conf /etc/rsyslog.d/10-swift.conf
COPY ./misc/supervisord.conf /etc/supervisord.conf

RUN	easy_install supervisor; mkdir /var/log/supervisor/ && \
    # create swift user and group
    /usr/sbin/useradd -U swift && \
    sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync && \
    sed -i 's/SLEEP_BETWEEN_AUDITS = 30/SLEEP_BETWEEN_AUDITS = 86400/' /usr/local/src/swift/swift/obj/auditor.py && \
    sed -i 's/\$PrivDropToGroup syslog/\$PrivDropToGroup adm/' /etc/rsyslog.conf && \
    sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
    mkdir -p /var/log/swift/hourly; chown -R syslog.adm /var/log/swift; chmod -R g+w /var/log/swift && \
    ln -s /swift/nodes/1 /srv/1 && \
    mkdir -p /swift/nodes/1 /srv/1/node/sdb1 /var/run/swift /var/cache/swift && \
    chown -R swift:swift /swift/nodes /etc/swift /srv/1 /var/run/swift /var/cache/swift

EXPOSE 8080
CMD ["/bin/bash", "/swift/bin/launch.sh"]
