## Gitops / ArgoCD Demo

Aşağıdaki linkten, LOG IN VIA OPENSHIFT seçeneği ile ArgoCD'ye login olunur:

https://openshift-gitops-server-openshift-gitops.apps.ocp-qua-test.quasys.com.tr/

<img width="1280" height="650" alt="image" src="https://github.com/user-attachments/assets/364fa921-4d91-4bd3-b894-91c78b6516ee" />

Authorize access uyarısı çıkarsa, Allow selected permissions ile devam edilir.

<img width="1213" height="434" alt="image" src="https://github.com/user-attachments/assets/3a5854ec-393b-4450-8e82-ca1235cdf32e" />

Ana ekranda, Create Application'a tıklanır:

<img width="1247" height="709" alt="image" src="https://github.com/user-attachments/assets/e9e5144f-06cb-4e50-a6b6-d88e93fd0441" />

Application name: argocd-demo-project1 #project1 değeri, demo user numarası ile aynı olmalıdır.
Project: default
Sync Policy Manual
<img width="1476" height="810" alt="image" src="https://github.com/user-attachments/assets/946bd4d2-e0e0-4b37-9f1c-88a6b0f74173" />


Source
Repository URL: https://github.com/oemreclk/openshift-gitops-examples
Revision: HEAD
Path: apps/bgd/overlays/demo-project1 #demo-project1 değeri kullanılan demo-user'a göre değişmektedir. demo-user4 kullanılıyorsa path apps/bgd/overlays/demo-project4 olmalıdır.

<img width="1474" height="408" alt="image" src="https://github.com/user-attachments/assets/42813f6a-5857-44ba-af82-3efa5cc66eba" />

Destination
Cluster URL: https://kubernetes.default.svc
Namespace: demo-project1 # Bu değer kullanılan demo-user'a göre değişmektedir. demo-user4 için demo-project4 kullanılmalıdır.

<img width="1460" height="294" alt="image" src="https://github.com/user-attachments/assets/99a8ba59-74ce-4f81-bf61-0446f0e9058b" />

Application create edildikten sonra, sync tuşu ile deploy edilir:

<img width="1253" height="739" alt="image" src="https://github.com/user-attachments/assets/97b7dadd-48f7-4adf-a51b-e2ecfca6d63a" />

Sync ettikten sonra, openshift ortamına ilgili resource'lar deploy olacaktır. Health ve Synced ibareleri görülmelidir:

<img width="1543" height="779" alt="image" src="https://github.com/user-attachments/assets/bf54b2db-18da-41f5-838a-02451b368f36" />

Argocd ile deploy edilen resource'ları kontrol etmek için Openshift Console'a login olunur:

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

Workloads > Deployments altından deploy olan uygulama görüntülenebilir.

Networking > Routes sekmesi altından, linke tıklanarak uygulama açılabilir:

<img width="1425" height="709" alt="image" src="https://github.com/user-attachments/assets/9e656ccb-998a-439e-9e85-2da1c97edb2a" />

<img width="1352" height="781" alt="image" src="https://github.com/user-attachments/assets/206af49b-8f0a-495d-b9ad-d37b87be9f0a" />

Uygulamadaki topların renkleri , deployment objesi altında belirlenmektedir.

Worklaods > Deployments > 



