Enter the cluster with provided infos from your tutor.

<img width="1462" height="782" alt="image" src="https://github.com/user-attachments/assets/3350eda1-69b8-411a-8616-56126d0c7ddd" />



Head over to the Workloads -> Deployments section and make sure to select youyr namespace from top left corner.
Then create the deployment and service instance we are gonna use


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
        team: demo-app
    spec:
      containers:
      - name: nginx
        image: docker.io/nginxinc/nginx-unprivileged:stable
        ports:
        - containerPort: 8080
        securityContext:
          runAsNonRoot: true
          allowPrivilegeEscalation: false
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 50m
            memory: 64Mi
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-app-svc
spec:
  selector:
    app: demo-app
  ports:
  - port: 80
    targetPort: 8080
```

After that make sure the pods run via Workloads->Pods section. Expected is 1 pod at Running State.

Than head over to pod details and clicked at the Terminal tab at the right top corner.
At the terminal type `curl orange-svc.testorange.svc.cluster.local` to make sure that you can access an web nginx application.

Than at a web new page head over to the Networking->Network Policies and create the first network policie that blocks both egress and ingress traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}        
  policyTypes:
  - Ingress
  - Egress
```


Than try to run the `curl orange-svc.testorange.svc.cluster.local` command again to releaize that connection is blocked.

To allow connection add another network policie with egress traffic allowed to a spesific pod in a spesific namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-demo-app-egress-to-orange
spec:
  podSelector:
    matchLabels:
      app: demo-app
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: testorange
      podSelector:
        matchLabels:
          app: orange
    ports:
    - port: 8080
      protocol: TCP
```

Try to access to it via `curl orange-svc.testorange.svc.cluster.local`. It will fail again because we didint allow the coreDNS connection for gathering service isntance ip address. But we can access it with service instance ip address directly with `curl 172.30.202.143` command. After that for allowing the CoreDns access for dns resulutions apply the next network policie.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-to-core-dns
spec:
  podSelector:
    matchLabels:
      app: demo-app
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: openshift-dns
      ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
        - port: 5353
          protocol: UDP
        - port: 5353
          protocol: TCP
```

Than try to use `curl orange-svc.testorange.svc.cluster.local` command again at the pod and make sure that it can access the pod via service instance hostname entry.

Create a route instance at Networking -> Routes -> Create Route
<img width="1500" height="762" alt="image" src="https://github.com/user-attachments/assets/0ebbe383-2da6-4cf2-9909-0fb630e042d6" />   
<img width="1512" height="727" alt="image" src="https://github.com/user-attachments/assets/a03cdacf-b42b-4b1a-b179-746cf2ac5f95" />

Than try to access it via url address givin from the freshly created route instance

<img width="1495" height="860" alt="image" src="https://github.com/user-attachments/assets/fa2cece0-983b-4934-a9b0-3178870bbca8" />   
<img width="1871" height="627" alt="image" src="https://github.com/user-attachments/assets/a2513faa-bb41-4146-af8c-ff8969757fb9" />

The application is not avaible because the block all ingress policy blocking traffic coming form router pods at openshift-ingress project. So we need to add an Network Policie that allows that trafic.

For route access apply also this Network Policie

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-router
spec:
  podSelector:
    matchLabels:
      app: demo-app
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              network.openshift.io/policy-group: ingress
      ports:
        - port: 8080
          protocol: TCP
```

After that refresh the page of route instance url and confirm that its accecable

<img width="885" height="412" alt="image" src="https://github.com/user-attachments/assets/e53de6de-2ce0-4590-8c7d-56d661e3f98f" />

