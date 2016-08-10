# Testing a microservices demo application with Traffic Control in Weave Scope

This demo demonstrates how the traffic control plugin in Weave Scope can be used to test a [generic microservices demo application](https://github.com/microservices-demo/microservices-demo).
It uses [Kubernetes](http://kubernetes.io/) on [CoreOS Linux](https://coreos.com/)  and [Weave Scope](https://github.com/weaveworks/scope) together.

## Install Kubernetes on Vagrant

Follow the instructions on [Single-Node Kubernetes Installation with Vagrant & CoreOS](https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant-single.html). I used the single node configuration:

```
$ git clone https://github.com/coreos/coreos-kubernetes.git
$ cd coreos-kubernetes/single-node
$ vim Vagrantfile # add memory: NODE_MEMORY_SIZE = 4096 ; you can add CPUs too: v.cpus = 4
$ vagrant up --provider virtualbox
```

It might take a while to start the VM the first time, specially on a slow network.
Once installed, check that `kubectl` works properly:
```
$ export KUBECONFIG=$(pwd)/kubeconfig
$ kubectl config use-context vagrant-single
$ kubectl get nodes
```

Update your `~/.ssh/config` with the content of `vagrant ssh-config`.
Check that you can ssh to `coreos`.
I added the following port forwarding to be able to connect to the pods we will create later:
```
  LocalForward 9101 10.3.0.31:80
  LocalForward 9102 10.3.0.32:80
  LocalForward 4040 10.3.0.61:4040
```

## Install the generic microservices demo application

The `wholeWeaveDemo-copy.yaml` yaml file originally come from [microservices-demo](https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/definitions/wholeWeaveDemo.yaml).

```
$ git clone https://github.com/kinvolk/demo.git
$ cd demo/traffic-control-microservices-demo
$ kubectl create -f wholeWeaveDemo-copy.yaml
```

## Install tcd and Weave Scope

```
$ kubectl create -f scope.yaml
```

## Prepare your browser for the demo

Keep a terminal open with ssh redirections defined before.
```
$ ssh coreos
```

And save the following bookmarks in your browser:
- "Weave Scope": [http://localhost:4040/](http://localhost:4040/)
- "Socks V1": [http://localhost:9101/](http://localhost:9101/)
- "Socks V2": [http://localhost:9102/](http://localhost:9102/)
- "Front-end Patch": [commit 15e96eb07d9a](https://github.com/kinvolk/microservices-demo/commit/15e96eb07d9a42149d28ed3814bd8be9b7721c0a)

## Demo 1

- Go to "Socks V1" in the browser
- Login. You can use `user1/password1`
- Add the "holy" socks in the cart
- Refresh (it seems to work)
- Locate the front-end-v1 container
- Add latency on front-end-v1
- Notice how refreshing the cart page becomes slow
- Notice that there is no user feedback whether the guestbook is fully loaded
- Go to "Front-end Patch" in the browser to see how it can be fixed

## Demo 2

- See the same with "Socks V2" and "front-end-v2"
- Notice that this version has user feedback

## Demo 3: ginkgo

- Ensure that "front-end-v2" is setup with some latency
- Run ginkgo

```
$ cd weavesocks-test
$ ginkgo
```

## Scripts

If you need to delete and create the application in Kubernetes, you can use the scripts `create.sh` and `delete.sh`.

If you need to empty the cart, you can do that by recreating the cart database with `empty-db.sh`.


