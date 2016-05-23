# Traffic Control on OpenShift
This demo demonstrates how to use traffic control to test applications running in [OpenShift](https://www.openshift.com/). It uses OpenShift version 3 to run the Kubernetes cluster, [tcd](https://github.com/kinvolk/tcd) to do traffic control on the Kubernetes nodes and [Weave Scope](https://github.com/weaveworks/scope) to monitor, visualize and interact with the Kubernetes cluster.

To find more information about traffic control and this demo check our [blog post](https://kinvolk.io/blog/2016/05/testing-web-services-with-traffic-control-on-kubernetes/).

### What do you need to start?
- Get an [OpenShift ready VM](https://github.com/kinvolk/openshift-evangelists-vagrant-origin) to run the demo.
- Get the [demo](https://github.com/kinvolk/demo) repository.

### Get the VM
```
git clone https://github.com/kinvolk/openshift-evangelists-vagrant-origin.git
cd openshift-evangelists-vagrant-origin
vagrant up
```
The building process could take several minutes depending of your machines because it is installing additional packages on top of a Fedora base image, and then fetching the last openshift sources and then build it. The final output should look like this:

```
==> default: You can now access OpenShift console on: https://10.2.2.2:8443/console
==> default: To use OpenShift CLI, run:
==> default: $ vagrant ssh
==> default: $ sudo -i
==> default: $ oc status
==> default: $ oc whoami
==> default: If you have the oc client library on your host, you can also login from your host.
==> default: $ oc login https://10.2.2.2:8443
```
To reboot you can do
```
vagrant halt; vagrant up
```
You need to reboot the VM after the first `vagrant up` in order to load the right kernel version and to load the modules needed by tcd.

For convenience, you can add to your ~/.ssh/config the output of `vagrant ssh-config` using as host name `openshift` and add the following lines.

```
LocalForward 1931 172.30.8.64:4040
LocalForward 8082 172.30.8.92:80
LocalForward 8083 172.30.8.93:80
```

Keep a `ssh openshift` session open and the ssh port forwarding will allow you to access to the Weavescope dashboard from [http://127.0.0.1:1931](http://127.0.0.1:1931).

You can reach the OpenShift dashboard at [https://10.2.2.2:8443](https://10.2.2.2:8443). Use user "admin" and password "admin" to login.

### Prepare for the demo
- Copy the .yaml files into the VM from the "traffic-control-openshift" directory of the demo repository and the potato_test directory.

```
scp demo/traffic-control-openshift/*.yaml vagrant@openshift:~/
scp -r demo/traffic-control-openshift/potato_test vagrant@openshift:~/
```

Before running the demo you should check that the following kernel modules can successfully be loaded:

```
sudo modprobe ifb
sudo modprobe sch_netem
```

## Running the demo
After logging into the VM you need to login into the `oc` command line tool using username "admin" and password "admin" in order to create projects and applications.

Example:

```
oc login https://10.2.2.2:8443

...
...
oc new-project demo

```
Now you are working on the project __demo__, before you can deploy the services you need to set the policy as shown below.
```
oc adm policy add-scc-to-user privileged system:serviceaccount:demo:default
```
This is necessary because tcd and weavescope-probe need to run as a privileged user to use some resources e.g. hostNetwork, hostPID, and hostPath.

After you set up the policy, you can deploy the demo:


```
oc create -f openshift-tcd-scope.yaml
### replicationcontroller "tcd" created
### replicationcontroller "weavescope-app" created
### service "weavescope-app" created
### replicationcontroller "weavescope-probe" created

oc create -f ping.yaml
...

oc create -f guestbook-all-in-one.yaml
...
```

The first line creates a pod for our traffic control daemon with integration for Weavescope.
Then you create multiple pods running a simple ping application, which downloads a small file from a server in a loop.
The last command deploys a guestbook application with two different versions of the frontends and one backend.

### Play with the demo

You can play with the demo following these instructions:

- [Ping demo](https://github.com/kinvolk/demo/tree/master/traffic-control-k8s#demo-1)
- [Guestbook demo](https://github.com/kinvolk/demo/tree/master/traffic-control-k8s#demo-2)


## Clean up and shutdown

The following commands will destroy the pods and shutdown the VM.

```
oc delete -f openshift-tcd-scope.yaml
...
...
oc delete -f ping.yaml
...
oc delete -f guestbook-all-in-one.yaml
...
...
exit

vagrant halt
```
