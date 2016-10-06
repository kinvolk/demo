#!/usr/bin/env bash
set -ex

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

IMG_NAME="skype.com/skype"
VERSION="4.3.0"
ARCH=amd64
OS=linux

FLAGS=${FLAGS:-""}
ACI_FILE=skype-"${VERSION}"-"${OS}"-"${ARCH}".aci

function acbuildend() {
    export EXIT=$?;
    acbuild --debug end && rm -rf rootfs && exit $EXIT;
}

echo "Generating skype ACI with nix"

acbuild begin
trap acbuildend EXIT

acbuild $FLAGS label add arch amd64
acbuild $FLAGS label add os linux
acbuild $FLAGS label add version $VERSION
acbuild $FLAGS set-name $IMG_NAME

for i in $(nix-store -qR out/); do sudo acbuild $FLAGS copy $i $i; done

acbuild $FLAGS environment add PATH `realpath out`/bin
acbuild $FLAGS set-exec skype

acbuild mount add x11socket /tmp/.X11-unix
acbuild mount add machineid /etc/machine-id

# Run nginx in the foreground
acbuild write --overwrite $ACI_FILE
