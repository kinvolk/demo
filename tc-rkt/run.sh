#!/bin/bash

sudo rkt run --insecure-options=image \
	--volume=files,kind=host,source=/home/alban/Videos \
	--port=rtsp:5554 \
	./rtp-demo-latest-linux-amd64.aci

