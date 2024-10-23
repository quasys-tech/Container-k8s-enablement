https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
https://kubernetes.io/docs/concepts/services-networking/ingress/
https://kubernetes.io/docs/concepts/services-networking/network-policies/

Openshift SDN vs OVN Kubernetes CNI Plugin Comparison
--------------
![image](https://github.com/user-attachments/assets/864c30e3-8b83-4ac4-a24d-2854394ac104)


Openshift CNI Details
--------------
oc get network.operator cluster -o yaml

Openshift Node Network Details
--------------
oc get node <node-name> -o yaml | grep k8s.ovn.org/node-subnets

