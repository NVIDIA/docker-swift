#!/bin/sh
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcached start

# set up storage
/usr/bin/sudo -u swift /swift/bin/remakerings
/usr/bin/sudo -u swift /swift/bin/startmain
/usr/bin/sudo -u swift /swift/bin/startrest
/usr/local/bin/supervisord -n -c /etc/supervisord.conf
