#!/bin/sh
/usr/sbin/service rsync start
ps -ef | grep rsyncd 
/usr/bin/sudo -u swift /swift/bin/remakerings
/usr/bin/sudo -u swift /swift/bin/startmain
