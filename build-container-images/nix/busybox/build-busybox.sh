#!/usr/bin/env bash
set -ex

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

IMG_NAME="busybox.net/busybox"
VERSION="1.23.2"
ARCH=amd64
OS=linux

FLAGS=${FLAGS:-""}
ACI_FILE=busybox-"${VERSION}"-"${OS}"-"${ARCH}".aci

function acbuildend() {
    export EXIT=$?;
    acbuild --debug end && rm -rf rootfs && exit $EXIT;
}

echo "Generating busybox ACI with nix"

acbuild begin
trap acbuildend EXIT

acbuild $FLAGS label add arch amd64
acbuild $FLAGS label add os linux
acbuild $FLAGS label add version $VERSION
acbuild $FLAGS set-name $IMG_NAME
acbuild $FLAGS set-user 0
acbuild $FLAGS set-group 0

for i in $(nix-store -qR out/); do sudo acbuild $FLAGS copy $i $i; done

acbuild $FLAGS environment add PATH `realpath out`/bin
acbuild $FLAGS set-exec sh
# Run nginx in the foreground
acbuild write --overwrite $ACI_FILE
