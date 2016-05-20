# Traffic Control on OpenShift
This demo demonstrates how to use traffic control to test applications running in [OpenShift](https://www.openshift.com/). It uses OpenShift version 3 to run the Kubernetes cluster, [tcd](https://github.com/kinvolk/tcd) to do traffic control on the Kubernetes nodes and [Weave Scope](https://github.com/weaveworks/scope) to monitor, visualize and interact with the Kubernetes cluster.

## What do you need to start?
- Get an [OpenShift ready VM](https://github.com/kinvolk/openshift-evangelists-vagrant-origin) to run the demo. You will need to to reboot the VM after the first `vagrant up` in order to load the right kernel version and to load the modules needed by tcd.
- Get the [demo](https://github.com/kinvolk/demo) repository

You can reach the OpenShift dashboard by pointing your browser to [https://10.2.2.2:8443](https://10.2.2.2:8443). Use user 'admin' and password 'admin' to login.

For convenience, you can add this to your ~/.ssh/config the output of ```vagrant ssh-config``` and add the following lines.

```ssh
     LocalForward 1931 172.30.8.64:4040
     LocalForward 8082 172.30.8.92:80
     LocalForward 8083 172.30.8.93:80
```

This will allow you to use this [http://127.0.0.1:1931](http://127.0.0.1:1931) to access the Weavescope dashboard.

- Copy the .yaml files into the VM from the "traffic-control-openshift" directory of the demo repository.
```
scp -r demo/traffic-control-openshift/* vagrant@<OPENSHIFT_VM_HOSTNAME>:~/
```

## Running the demo
After logging into the VM you need to login into the ```oc``` command line tool using username "admin" and password "admin" in order to create projects and applications.

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
oc create -f apps/openshift-tcd-scope.yaml
### replicationcontroller "tcd" created
### replicationcontroller "weavescope-app" created
### service "weavescope-app" created
### replicationcontroller "weavescope-probe" created

oc create -f apps/ping.yaml
...

oc create -f apps/guestbook-all-in-one.yaml
...
```

The first line creates a pod for our traffic control deamon with integration for Weavescope.
Then you create multiple pods running a simple ping application, which downloads a small file from a server in a loop.
The last command deploys a guestbook application with two different versions of the frontends and one backend.

