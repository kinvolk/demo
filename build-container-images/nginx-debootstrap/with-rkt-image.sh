#!/bin/bash

sudo rkt run \
    --insecure-options=image,http \
    --volume=index,kind=host,source=/var/tmp/rkt \
    docker://localhost:5000/nginx \
    --mount volume=index,target=/usr/share/nginx/html
