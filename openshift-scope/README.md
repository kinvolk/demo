# Weave Scope on OpenShift
This demo demonstrates how to install and run [Weave Scope](https://github.com/weaveworks/scope) on [OpenShift](https://www.openshift.com/).

### What do you need to start?
- Get an [OpenShift ready VM](https://github.com/kinvolk/openshift-evangelists-vagrant-origin) to run the demo.
- Get the [demo](https://github.com/kinvolk/demo) repository.

### Get the VM

```
git clone https://github.com/kinvolk/openshift-evangelists-vagrant-origin.git
cd openshift-evangelists-vagrant-origin
```

Make sure the `Vagrantfile` has the following changes:
- Fedora 25
- 8GB mempory

```
VM_MEM = ENV['ORIGIN_VM_MEM'] || 8192 # Memory used for the VM
...
   config.vm.box = "fedora/25-cloud-base"
```

Now you can start the VM:

```
vagrant up --provider=virtualbpx
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

Install additional packages:
```
dnf install kernel-debug-modules-extra kernel-devel
```

Disable the Docker option [blkdiscard](https://github.com/kinvolk/openshift-evangelists-vagrant-origin/commit/fd1f9ca71eedfbb78a2afe716a81c7fc01f9db26). Otherwise, kswapd will take 100% cpu.

To reboot you can do
```
vagrant halt; vagrant up
```

You need to reboot the VM after the first `vagrant up` in order to load the right kernel version and to load the modules needed by Weave Scope plugins.

For convenience, you can add to your ~/.ssh/config the output of `vagrant ssh-config` using as host name `openshift` and add the following lines.

```
LocalForward 1931 172.30.8.64:4040
LocalForward 8082 172.30.8.92:80
```

Keep a `ssh openshift` session open and the ssh port forwarding will allow you to access to the Weavescope dashboard from [http://127.0.0.1:1931](http://127.0.0.1:1931).

You can reach the OpenShift dashboard at [https://10.2.2.2:8443](https://10.2.2.2:8443). Use user "admin" and password "admin" to login.

### Prepare for the demo

- Copy the .yaml files into the VM from the "openshift-scope" directory of the demo repository.

```bash
scp demo/openshift-scope/*.yaml vagrant@openshift:~/
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
oc new-project weavescope
```
Now you are working on the project __weavescope__, before you can deploy the services you need to set the policy as shown below.
```
oc adm policy add-scc-to-user privileged system:serviceaccount:weavescope:default
oadm policy add-cluster-role-to-user cluster-admin system:serviceaccount:weavescope:default
```
This is necessary because the Weave Scope Agent needs to run as a privileged user to use some resources e.g. hostNetwork, hostPID, and hostPath.

After you set up the policy, you can deploy the demo:

```
oc create -f weavescope.yaml
oc create -f weavescope-plugins.yaml
```

Check the cluster IP address for the `weave-scope-app` service:

```
oc get svc -n weavescope
```

And update your `~/.ssh/config`:
```
LocalForward 1931 172.30.8.64:4040
```

Add more pods per node: `/var/lib/origin/openshift.local.config/node-origin/node-config.yaml`
```
kubeletArguments:
  max-pods:
  - "100"
  podsPerCore:
  - "100"
```

Starting the sock shop:
```
oc create -f sock-shop.yaml
```
You might notice that I removed all the `securityContext` from the [original yaml file](https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml).
This is because OpenShift would reject them.

### Play with the demo

- Show the general Weave Scope UI
- Show the Sock Shop
- Show the traffic control plugin
- Show the HTTP statistics plugin


