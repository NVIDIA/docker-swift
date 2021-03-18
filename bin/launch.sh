#!/bin/sh
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcached start

# set up storage
su swift /swift/bin/remakerings
su swift -c "/usr/local/bin/swift-init main start"
su swift -c "/usr/local/bin/swift-init rest start"
/usr/local/bin/supervisord -n -c /etc/supervisord.conf
