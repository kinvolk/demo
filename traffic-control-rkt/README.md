# Demo: traffic control on a RTSP server in a rkt pod

This demo simulates varying network issues with Linux traffic control between a RTP/RTSP media server running in the rkt container runtime and a video player.

## Install software

- Install [rkt 1.0](https://github.com/coreos/rkt/releases/tag/v1.0.0)
- Install [acbuild 0.2.2](https://github.com/appc/acbuild/releases/tag/v0.2.2)
- Make sure you can load the kernel module `sch_netem`. In Fedora, install `kernel-modules-extra`.

## Build the RTSP container image

```
$ sudo ./build-rtp.sh
(...)
$ ls -lh rtp-demo-latest-linux-amd64.aci
-rw-r--r--. 1 root root 30M Feb  7 17:44 rtp-demo-latest-linux-amd64.aci

```

## Start the rkt pod

Download `ED_1024.avi` from the [Elephants Dream website](https://orange.blender.org/download/) in `~/Videos/`.

Start the rkt pod:
```
$ ./run.sh
```

The directory `~/Videos/` will be available as `/opt/` in the pod. But `vlc` requires more configuration to use the correct file:
```
$ sudo nsenter -t $(pidof vlc) -n telnet 127.0.0.1 4212
Password: videolan

new MyVideo vod enabled
setup MyVideo input "file:///opt/ED_1024.avi"
logout
```

## Start the video player

```
$ vlc rtsp://127.0.0.1:5554/MyVideo
```

## Start the network emulator GUI

```
$ ./tceditor.sh
```
