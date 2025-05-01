#!/bin/sh
ip route add local default dev lo table 100
ip rule add fwmark 1 lookup 100
/sbin/iptables-restore /etc/iptables/rules.v4
/usr/bin/v2ray $@
