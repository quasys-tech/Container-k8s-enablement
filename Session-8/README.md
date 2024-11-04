Redhat CoreOS Operating System
------------
https://docs.openshift.com/container-platform/4.16/architecture/architecture-rhcos.html

List API Resources from ETCDCTL
------------

      vagrant@container101-ubuntu:~$ kubectl get pods -n kube-system
      NAME                               READY   STATUS    RESTARTS        AGE
      coredns-6f6b679f8f-dd4n6           1/1     Running   3 (5d22h ago)   14d
      etcd-minikube                      1/1     Running   3 (5d22h ago)   14d
      kube-apiserver-minikube            1/1     Running   3 (5d22h ago)   14d
      kube-controller-manager-minikube   1/1     Running   3 (5d22h ago)   14d
      kube-proxy-vrsfh                   1/1     Running   3 (5d22h ago)   14d
      kube-scheduler-minikube            1/1     Running   3 (5d22h ago)   14d
      storage-provisioner                1/1     Running   7 (27m ago)     14d
      vagrant@container101-ubuntu:~$ kubectl exec -it etcd-minikube -n kube-system -- sh
      sh-5.2# export ETCDCTL_API=3
      sh-5.2# export ETCDCTL_ENDPOINTS="https://127.0.0.1:2379"
      sh-5.2# export ETCDCTL_CACERT="/var/lib/minikube/certs/etcd/ca.crt"
      sh-5.2# export ETCDCTL_CERT="/var/lib/minikube/certs/etcd/server.crt"
      sh-5.2# export ETCDCTL_KEY="/var/lib/minikube/certs/etcd/server.key"
      
      #Lists all resources in kubernetes.
      sh-5.2# etcdctl get / --prefix --keys-only
      
      sh-5.2# etcdctl get /registry/secrets/default/dotfile-secret
      /registry/secrets/default/dotfile-secret
      k8s
      
      
