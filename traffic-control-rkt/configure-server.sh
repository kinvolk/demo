#!/usr/bin/env bash

if [ $(id -u) != 0 ] ; then
  echo "Not root"
  exit 1
fi

VLC_PID=$(pidof vlc)
if [ -z "$VLC_PID" ] ; then
  echo "vlc server not running"
  exit 1
fi

read -d '' EXPECT_SCRIPT <<EOF
set timeout 4

spawn sudo nsenter -t $VLC_PID -n telnet 127.0.0.1 4212

expect "Password: "
send "videolan\\\\r"
expect ">"
send "new MyVideo vod enabled\\\\r"
expect ">"
send "setup MyVideo input file:///opt/ED_1024.avi\\\\r"
expect ">"
send "logout\\\\r"
expect eof
EOF

expect -f <(echo "$EXPECT_SCRIPT")
