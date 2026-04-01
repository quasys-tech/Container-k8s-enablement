We are gonna create an nginx web application that requires previlged scc to run on the OpenShhift Cluster. In OpenShift applications requires scc's to be added manually the default service accounts on custom projects wont gonna have any previlged scc.   

Create the nginx privileged Demo Deployment   

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-privileged-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-privileged-demo
  template:
    metadata:
      labels:
        app: nginx-privileged-demo
    spec:
      containers:
      - name: nginx
        image: docker.io/library/nginx:latest
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 0
          privileged: true
          allowPrivilegeEscalation: true
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 50m
            memory: 64Mi
```

Create the service instance 
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-privileged-svc
spec:
  selector:
    app: nginx-privileged-demo
  ports:
    - name: http
      port: 80
      targetPort: 80
```

Create the Route isntance   

Head over to the Networkings->Routes->Create Route from web ui
<img width="2535" height="1077" alt="image" src="https://github.com/user-attachments/assets/73e09eaf-f559-4792-8b54-2211188ab07e" />   


Create the route instance from form view, leave hostname as empty and path as "/". As service chose nginx-privileged-svc and "80 -> 8080" as target port.   
Enable secure route box and select  edge as TLS termination method and none as Insecure traffic. Leave the tls certifiacte boxes empty and create the  route isntance.    
<img width="1207" height="937" alt="image" src="https://github.com/user-attachments/assets/ee730d04-069a-4b1d-90b1-5cd9ccf33657" />   
<img width="1207" height="1063" alt="image" src="https://github.com/user-attachments/assets/37c1a289-0e6a-4993-a75d-7568391aca54" />   

Test the access to the router isntance via givin url at Network -> Routes -> Newly created route    
<img width="1186" height="1046" alt="image" src="https://github.com/user-attachments/assets/74368e90-455b-4c5a-837a-3d9b2aebe08f" />   
When clicked at the url address the web page will say that `Application is not available`.

For debugging head over to the service isntance from Network->Services and select our service instance. Then you'll notice there are no pods to forward to traffic at Pods page   
<img width="1226" height="1045" alt="image" src="https://github.com/user-attachments/assets/c74bd17d-0a1c-475b-9e31-8db95ed082a7" />

Head over to the deployments page and select our nginx-privileged-demo. You'll releaize that it has no pod even the `replicas: 1` chosed as 1.   
<img width="1197" height="508" alt="image" src="https://github.com/user-attachments/assets/00ad5fa7-6bae-4a59-a476-2cc8b41e3fac" />   

At the Conditions part bellow the deployment details webpage we can spot an ReplicaFailure condition.   
<img width="1163" height="1047" alt="image" src="https://github.com/user-attachments/assets/df2ee186-786e-45e1-a93e-7b3295e11272" />   

This error tells us that our Deployment explicitly requests `runAsUser: 0` and `privileged: true` but it violates the default restricted-v2 SCC assigned to your project. So we need to create our own serviceaccount and give the neccecary scc's to it.   
We can aslo give those permits to default service account that gets created when the project is created but by that every pod that uses default serviceaccount will have those scc's.

Create the service account  via cli. Login the openshift cluster via oc login command givin from your instructer to login from your lab env vli or select the commandline button at the top right part of the cluster gui.   
<img width="1217" height="310" alt="image" src="https://github.com/user-attachments/assets/d7fc8724-e0ff-4c5a-bb5b-9a04f9184b0d" />

Than type the command bellow to create your service account.
```code
oc create sa demo-thy-sa
````
Than give the neccecary privileged scc to thhe service account via the command bellow
```code
oc adm policy add-scc-to-user privileged -z demo-thy-sa
```

This command will dail because of the lack of permits your demo-user has. To solve this porblem lab project already has a service account name demo-sa with privileged scc at every demo project. Type `oc get sa` to list the sa at your project.
```code
udu@Ubuntu1:~/Desktop/openshift-datacenter$ oc get sa
NAME       SECRETS   AGE
builder    1         6d21h
default    1         6d21h
demo-sa    1         42m
deployer   1         6d21h
```

Than edit the deployment yaml file to add the serviceaccount at the nginx-privileged-demo deployment. Hit to yaml view and go to second spec: section at line 120 ~. You should see something like bellow
```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-privileged-demo
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-privileged-demo
    spec:
      containers:
        - name: nginx
          image: 'docker.io/library/nginx:latest'
```
The service account info will typed at the second spec: section like bellow
```yaml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-privileged-demo
  template:
    metadata:
      labels:
        app: nginx-privileged-demo
    spec:
      serviceAccountName: demo-sa   # <- service account info
      containers:
      - name: nginx
        image: docker.io/library/nginx:latest
```

Enter the serviceAccountName line and save the yaml. If you get errors or strugle at yaml view you can delete the deployment and recrteate it with the yaml bellow
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-privileged-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-privileged-demo
  template:
    metadata:
      labels:
        app: nginx-privileged-demo
    spec:
      serviceAccountName: demo-sa
      containers:
      - name: nginx
        image: docker.io/library/nginx:latest
        ports:
        - containerPort: 80
        securityContext:
          runAsUser: 0
          privileged: true
          allowPrivilegeEscalation: true
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 50m
            memory: 64Mi
```

After that check the pods to make sure they get created and running.   
<img width="1223" height="630" alt="image" src="https://github.com/user-attachments/assets/53223f6b-68e3-4cff-bddb-b1b19682c42d" />   

Than head over to the route address and validate your application is running and reachable.   
<img width="1458" height="495" alt="image" src="https://github.com/user-attachments/assets/bc4f9773-8275-4e49-8d79-f12d03f651db" />
