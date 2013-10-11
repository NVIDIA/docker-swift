#!/bin/sh
/usr/sbin/service rsyslog start
/usr/sbin/service rsync start
/usr/sbin/service memcache start
ps -ef | grep rsyncd 
/usr/bin/sudo -u swift /swift/bin/startmain
/usr/local/bin/supervisord -n -c /etc/supervisord.conf
