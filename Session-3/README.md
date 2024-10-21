

LAB Environment Requirements
- Virtualbox
- Vagrant

Create LAB Environment
------------

        #Run Vagrant command in the Vagrant folder.
        >vagrant up


Connect to LAB Environment
------------

        #On the same folder which "vagrant up" run.
        >vagrant ssh ubuntu_vm

Change default namespace in kubectl
------------
      vagrant@container101-ubuntu:~/demo$ kubectl config set-context --current --namespace=k8s-intro


Connect to pod's terminal
------------

      vagrant@container101-ubuntu:~/demo$ kubectl exec -it k8s-intro-busybox -- /bin/sh


List All Kubernetes API Resources
------------

      vagrant@container101-ubuntu:~$ kubectl api-resources

List All Deployment in Current Namespace
------------

       vagrant@container101-ubuntu:~/demo$ kubectl get deployment
        NAME              READY   UP-TO-DATE   AVAILABLE   AGE
        k8s-intro-nginx   0/3     3            0           7s
