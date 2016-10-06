#!/bin/bash

sudo rkt run \
    --set-env=DISPLAY=unix$DISPLAY \
    --volume x11socket,kind=host,source=/tmp/.X11-unix \
    --volume machineid,kind=host,source=/etc/machine-id \
    skype-4.3.0-linux-amd64.aci \
    --user=$(id -u) \
    --group=$(id -g)
