#!/bin/bash

NAME=rtp-demo
POD=$(rkt list --full --no-legend|grep "^[0-9a-f-]*\s${NAME}\s.*running" |awk '{print $1}')
PID=$(rkt status $POD | grep '^pid=' | cut -d= -f2)

echo pod $POD
echo pid $PID

SETNETNS="sudo nsenter -t $PID -n"

if $SETNETNS tc qdisc show dev eth0 | grep -q '^qdisc noqueue' ; then
  $SETNETNS tc qdisc add dev eth0 root handle 1: netem
fi


$SETNETNS gjs ./tceditor.js

