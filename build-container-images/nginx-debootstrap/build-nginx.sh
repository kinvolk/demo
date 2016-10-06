#!/usr/bin/env bash
set -ex

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

IMG_NAME="nginx.com/nginx"
VERSION="1.10.1"
ARCH=amd64
OS=linux

FLAGS=${FLAGS:-""}
ACI_FILE=nginx-"${VERSION}"-"${OS}"-"${ARCH}".aci

PKGS="nginx"

function acbuildend() {
    export EXIT=$?;
    acbuild --debug end && rm -rf rootfs && exit $EXIT;
}

echo "Generating nginx ACI"

mkdir rootfs
debootstrap --variant=minbase --components=main --include="${PKGS}" sid rootfs http://httpredir.debian.org/debian/
rm -rf rootfs/var/cache/apt/archives/*

echo "Version: v${VERSION}"
echo "Building ${ACI_FILE}"

acbuild begin ./rootfs
trap acbuildend EXIT

acbuild $FLAGS set-name $IMG_NAME
acbuild $FLAGS label add version $VERSION
acbuild $FLAGS set-user 0
acbuild $FLAGS set-group 0
acbuild $FLAGS environment add OS_VERSION sid
# Run nginx in the foreground
acbuild --debug set-exec -- /usr/sbin/nginx -g "daemon off;"
acbuild write --overwrite $ACI_FILE
