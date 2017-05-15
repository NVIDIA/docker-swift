#!/bin/sh
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcached start
# set up storage
mkdir -p /swift/nodes/1 /swift/nodes/2 /swift/nodes/3 /swift/nodes/4
ln -s /swift/nodes/1 /srv/1; ln -s /swift/nodes/2 /srv/2; ln -s /swift/nodes/3 /srv/3; ln -s /swift/nodes/4 /srv/4 
mkdir -p /srv/1/node/sdb1 /srv/2/node/sdb2 /srv/3/node/sdb3 /srv/4/node/sdb4 /var/run/swift
/usr/bin/sudo /bin/chown -R swift:swift /swift/nodes /etc/swift /srv/1 /srv/2 /srv/3 /srv/4 /var/run/swift
/usr/bin/sudo -u swift /swift/bin/remakerings
/usr/bin/sudo -u swift /swift/bin/startmain
/usr/bin/sudo -u swift /swift/bin/startrest
/usr/local/bin/supervisord -n -c /etc/supervisord.conf
