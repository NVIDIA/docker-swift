#!/bin/sh
/etc/init.d/sysklogd start
/usr/sbin/service rsync start
/usr/sbin/service memcached start
/usr/bin/sudo -u swift /swift/bin/remakerings
/usr/bin/sudo -u swift /swift/bin/startmain
/usr/local/bin/supervisord -n -c /etc/supervisord.conf
