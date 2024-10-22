

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

Create a Pod with Yaml file
------------

        vagrant@container101-ubuntu:~/demo$ kubectl create -f pod-nginx.yml
        pod/nginx created
        vagrant@container101-ubuntu:~/demo$ kubectl get pods
        NAME    READY   STATUS    RESTARTS   AGE
        nginx   1/1     Running   0          3s

Connect to pod's terminal
------------

      vagrant@container101-ubuntu:~/demo$ kubectl exec -it k8s-intro-busybox -- /bin/sh


List All Kubernetes API Resources
------------

      vagrant@container101-ubuntu:~$ kubectl api-resources

Create a Deployment with Yaml file
------------

        vagrant@container101-ubuntu:~/demo$ kubectl create -f k8s-intro-nginx-deployment.yml --namespace k8s-intro
        deployment.apps/k8s-intro-nginx created
        vagrant@container101-ubuntu:~/demo$ kubectl get deployments.apps -n k8s-intro
        NAME              READY   UP-TO-DATE   AVAILABLE   AGE
        k8s-intro-nginx   1/3     3            1           9s
        vagrant@container101-ubuntu:~/demo$ kubectl get deployments.apps -n k8s-intro
        NAME              READY   UP-TO-DATE   AVAILABLE   AGE
        k8s-intro-nginx   3/3     3            3           12s
        vagrant@container101-ubuntu:~/demo$ kubectl get pods -n k8s-intro
        NAME                               READY   STATUS    RESTARTS       AGE
        k8s-intro-busybox                  1/1     Running   23 (27m ago)   39d
        k8s-intro-nginx-868fb977dd-2j8bf   1/1     Running   0              27s
        k8s-intro-nginx-868fb977dd-gpqpq   1/1     Running   0              27s
        k8s-intro-nginx-868fb977dd-zjqfw   1/1     Running   0              27s

List All Deployment in Current Namespace
------------

       vagrant@container101-ubuntu:~/demo$ kubectl get deployment
        NAME              READY   UP-TO-DATE   AVAILABLE   AGE
        k8s-intro-nginx   0/3     3            0           7s
