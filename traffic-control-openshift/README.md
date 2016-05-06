# Traffic Control on OpenShift

## What do you need to start?
- Get a OpenShift ready VM [here](https://github.com/kinvolk/openshift-evangelists-vagrant-origin) to run the demo. You need to __reboot__ the VM after you build it.
- Get get the demo repository [here](https://github.com/kinvolk/demo)
- Copy the .yaml files into the VM

By using ``` vagrant up ``` you run the VM, with ``` vagrant ssh ``` you can login, and ``` vagrant halt``` stops it.

You can reach the OpenShift dashboard with your browser at [https://10.2.2.2:8443](https://10.2.2.2:8443). Use user 'admin' and password 'admin' to login, now you are in the OpenShift dashboard.

For convenience you should add this to ~/.ssh/config

```ssh
Host kinvolk-demo
     HostName 127.0.0.1
     User vagrant
     Port 2222
     UserKnownHostsFile /dev/null
     StrictHostKeyChecking no
     PasswordAuthentication no
     IdentityFile "/path/to/your/demo/directory/openshift-evangelists-vagrant-origin/.vagrant/machines/default/virtualbox/private_key"
     IdentitiesOnly yes
     LogLevel FATAL
     LocalForward 1931 172.30.8.64:4040
     LocalForward 8082 172.30.8.92:80
     LocalForward 8083 172.30.8.93:80
```

This will allow you to use this [http://127.0.0.1:1931](http://127.0.0.1:1931) to access the Weavescope dashboard.

## Running the demo
After you are logged into the vm you need to login into the ```oc``` command line and use the username and password to be able to create projects and applications.
Example:

```
oc login https://10.2.2.2:8443

...
...
oc new-project demo

```

You __need__ to set the policy as shown below

```
oc adm policy add-scc-to-user privileged system:serviceaccount:demo:default
```
Now you are operating on the project __demo__, and we can deploy our demo:


```
oc delete -f apps/openshift-tcd-scope.yaml
oc delete -f apps/ping.yaml
oc delete -f apps/guestbook-all-in-one.yaml
```

The first line create a pod for our traffic control deamon with an integration with an integration with Weavescope.
Then we create multiple pods running a simple ping application, which download a small file from a server in a loop.
The last command deploy a guestbook application with two different versions of the frontends and a one backend.

