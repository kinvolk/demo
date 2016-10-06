#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

NGINX_VERSION="1.10.1"
NGINX_BUILD_DEPS="\
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		perl-dev"

# Start the build with an alpine ACI
acbuild --debug begin docker://alpine:3.4

# In the event of the script exiting, end the build
acbuildEnd() {
    export EXIT=$?
    acbuild --debug end && exit $EXIT
}
trap acbuildEnd EXIT

# Name the ACI
acbuild --debug set-name nginx.com/nginx
acbuild $FLAGS label add version $NGINX_VERSION

# Add nginx group and user
acbuild --debug run -- addgroup -S nginx
acbuild --debug run -- adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

# Install build deps
acbuild --debug run -- apk add --no-cache --virtual .build-deps ${NGINX_BUILD_DEPS}

# Get nginx sources
acbuild --debug run -- curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz
acbuild --debug run -- curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc

# Add, run and remove build from source script
acbuild --debug copy build-from-src.sh /build-from-src.sh
acbuild --debug run -- /build-from-src.sh $NGINX_VERSION
acbuild --debug run -- rm /build-from-src.sh

# Get missing nginx dependencies
acbuild --debug run -- apk add --no-cache --virtual .gettext gettext
acbuild --debug run -- mkdir -p /var/tmp/
acbuild --debug run -- mv /usr/bin/envsubst /var/tmp/

RUN_DEPS=$(acbuild --debug run -- /bin/sh -c "scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst" | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u)

acbuild --debug run -- apk add --no-cache --virtual .nginx-rundeps $RUN_DEPS
acbuild --debug run -- apk del .build-deps
acbuild --debug run -- apk del .gettext
acbuild --debug run -- mv /var/tmp/envsubst /usr/local/bin/

# forward request and error logs to docker log collector
acbuild --debug run -- ln -sf /dev/stdout /var/log/nginx/access.log
acbuild --debug run -- ln -sf /dev/stderr /var/log/nginx/error.log

# Add a port for http traffic over port 80
acbuild --debug port add http tcp 80
# Add a port for http traffic over port 443
acbuild --debug port add http tcp 443

# Add a mount point for files to serve
acbuild --debug copy nginx.conf /etc/nginx/nginx.conf

# Add a mount point for files to serve
acbuild --debug copy nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# Run nginx in the foreground
acbuild --debug set-exec -- /usr/sbin/nginx -g "daemon off;"

# Save the ACI
acbuild --debug write --overwrite nginx-$NGINX_VERSION-linux-amd64.aci
