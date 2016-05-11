# Traffic Control on OpenShift
This demo demonstrates how to use traffic control to test applications running in OpenShift. It uses OpenShift version 3, tcd and Weave Scope together: OpenShift orchestration system, tcd as traffic control application, and Wave Scope as visualize and to interact with the demo. 

## What do you need to start?
- Get a OpenShift ready VM from this [repository](https://github.com/kinvolk/openshift-evangelists-vagrant-origin) to run the demo, then you have to __reboot__ the VM after the first vagrant up to load the right kernel version and to load the modules needed by tcd.
- Get get the [demo](https://github.com/kinvolk/demo) repository

By using ``` vagrant up ``` you run the VM, with ``` vagrant ssh ``` you can login, and ``` vagrant halt``` stops it.

You can reach the OpenShift dashboard with your browser at [https://10.2.2.2:8443](https://10.2.2.2:8443). Use user 'admin' and password 'admin' to login, now you are in the OpenShift dashboard.

For convenience you should add this to your ~/.ssh/config the output of ``` vagrant ssh-config``` and add the following lines.

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
After you are logged into the vm you need to login into the ```oc``` command line tool using as username "admin" and password "admin" to be able to create projects and applications.
Example:

```
oc login https://10.2.2.2:8443

...
...
oc new-project demo

```
Now you are working on the project __demo__, before you can deploy the services you __need__ to set the policy as shown below.
```
oc adm policy add-scc-to-user privileged system:serviceaccount:demo:default
```
This is necessary because tcd and weavescope-probe need to run as privileged user to use some resources e.g. hostNetwork, hostPID, and hostPath.

After you set up the policy, you can deploy our demo:


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

The first line create a pod for our traffic control deamon with an integration for Weavescope.
Then you create multiple pods running a simple ping application, which download a small file from a server in a loop.
The last command deploy a guestbook application with two different versions of the frontends and a one backend.

