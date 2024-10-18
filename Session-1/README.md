Kubernetes

CRI: Container Runtime Interface (Container engines must support it for kubernetes.)

OCI (Open Container Initiative) has 2 domain imagespec, runtimespec.

Docker supported on kubernetes with dockershim until v1.24. After that version docker not supported as runtime. But images build with docker work, because docker support OCI imagespec.

Openshift CRI-O as the container engine runC as the container runtime

OpenShift Container Platform uses a software-defined networking (SDN) approach to provide a unified cluster network that enables communication between pods across the OpenShift Container Platform cluster. This pod network is established and maintained by the OpenShift SDN, which configures an overlay network using Open vSwitch (OVS).

Image Registry Commands
------------

      vagrant@container101-ubuntu:~/demo/nginx$ docker login quay.io
      # On the Docker-BUild/nginx folder
      vagrant@container101-ubuntu:~/demo/nginx$ docker build -t k8s-intro-nginx .
      #Replace repo/user name
      vagrant@container101-ubuntu:~/demo/nginx$ docker tag k8s-intro-nginx quay.io/<QUAY-IO-USER>/k8s-intro-nginx:latest
      vagrant@container101-ubuntu:~/demo/nginx$ docker push quay.io/emre_celik/k8s-intro-nginx:latest



