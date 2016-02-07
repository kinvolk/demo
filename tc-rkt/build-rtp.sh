#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

# Start the build with an empty ACI
acbuild --debug begin

# In the event of the script exiting, end the build
acbuildEnd() {
    export EXIT=$?
    acbuild --debug end && exit $EXIT 
}
trap acbuildEnd EXIT

# Name the ACI
acbuild --debug set-name kinvolk.io/rtp-demo

# Based on alpine
acbuild --debug dep add quay.io/coreos/alpine-sh

# Create user (vlc refuses to run as root)
acbuild environment add HOME /tmp
acbuild set-user 1000

# Install the rtp server
acbuild --debug run apk update
acbuild --debug run apk add vlc

# Add a port for rtsp traffic
acbuild --debug port add rtsp tcp 5554

# Add a mount point for files to serve
acbuild --debug mount add files /opt

# Run gstreamer in the foreground
acbuild --debug set-exec -- /usr/bin/vlc -I telnet --telnet-password videolan --rtsp-host 0.0.0.0 --rtsp-port 5554

# Save the ACI
acbuild --debug write --overwrite rtp-demo-latest-linux-amd64.aci
