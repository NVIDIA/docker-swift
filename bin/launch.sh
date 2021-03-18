#!/bin/sh
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcached start

# set up storage
su swift /swift/bin/remakerings
su swift /swift/bin/startmain
su swift /swift/bin/startrest

/usr/local/bin/supervisord -n -c /etc/supervisord.conf
