#!/bin/sh
# do not add Docker server to known_hosts, or next time auth will fail
ssh -o "UserKnownHostsFile /dev/null" -p `sudo docker ps | grep docker-swift | awk '{print $11;} ' | awk -F- '{print $1;}'` swift@localhost
