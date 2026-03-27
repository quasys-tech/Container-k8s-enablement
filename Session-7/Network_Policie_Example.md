Enter the cluster with provided infos from your tutor.

Head over to the Workloads -> Deployments section and make sure to select youyr namespace from top left corner.
Then create the deployment and service instance we are gonna use
----------------
mdyaml
```
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
  - port: 8080
    targetPort: 8080
----------------

After that make sure the pods run via Workloads->Pods section. Expected is 1 pod at Running State.

Than head over to pod details and clicked at the Terminal tab at the right top corner.
At the terminal type `curl http://orange-svc.testorange.svc.cluster.local:8080` to make sure that you can access an web nginx application.

Than at a web new page head over to the Networking->Network Policies and create the first network policie that blocks both egress and ingress traffic

--------------------------
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}        
  policyTypes:
  - Ingress
  - Egress
--------------------------


Than try to run the `curl http://orange-svc.testorange.svc.cluster.local:8080` command again to releaize that connection is blocked.

To allow connection add another network policie with egress traffic allowed to a spesific pod in a spesific namespace
-------------------------

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
-------------------------

Try to access to it via ``curl http://orange-svc.testorange.svc.cluster.local:8080`. It will fail again because we didint allow the coreDNS connection for gathering service isntance ip address. But we can access it with service instance ip address directly with `curl 172.30.244.135:8080` command. After that for allowing the CoreDns access for dns resulutions apply the next network policie.

------------------------------
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
------------------------------

Than try to use `curl http://orange-svc.testorange.svc.cluster.local:8080` command again at the pod and make sure that it can access the pod via service instance hostname entry.




For route access apply also this Network Policie

```bash
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
