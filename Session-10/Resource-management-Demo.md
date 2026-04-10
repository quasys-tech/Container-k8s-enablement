


## Limitrange Demo

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-10/k8s-resources/Deployment.yaml

Mevcut podların içerisinde, request limit değerlerinin olmadığı teyid edilir.

Workloads > Pods > webserver Pod > Yaml

<img width="1410" height="719" alt="image" src="https://github.com/user-attachments/assets/814087af-9ebf-48e1-9804-afd2f9806040" />

Administratin > Limitranges > Create limitranges altından aşağıdaki limitranges yaml ile limitrange create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-10/k8s-resources/limitrange.yaml

<img width="826" height="601" alt="image" src="https://github.com/user-attachments/assets/d4a8afe1-002a-499e-b261-e700f3acc394" />

Limitranges yaratıldıktan sonra Workloads > Deployments > webserver altından, deployment replicası 0 a çekilir.

<img width="1058" height="615" alt="image" src="https://github.com/user-attachments/assets/f3e0efb7-adb4-492e-b635-5fbb7d7fea23" />

0 a düştükten sonra, replica sayısı tekrar 3 olarak set edilir.

<img width="693" height="455" alt="image" src="https://github.com/user-attachments/assets/0164cedb-b6cc-43ec-b362-bb517464d9d7" />

Workloads > Pods > webserver > Yaml içerisine girilip "limits:" keywordu aranır. Deployment yaml içerisinde herhangi bir request/limit konfigürasyonu olmamasına rağmen yaratılan limitranges ile request ve limit değerlerinin geldiği görülür.

<img width="754" height="732" alt="image" src="https://github.com/user-attachments/assets/2d144ff5-11a2-4b67-8937-fd426deda27f" />

## ResourceQuota Demo

Limitranges demosu yapıldıysa, webserver deployment silinmelidir. Workloads > Deployment > webserver > Delete deployment

Limitranges demosu yapıldıysa, limitranges silinmelidir. Administration > Limitranges > mem-limit-range > Delete

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-10/k8s-resources/Deployment-loadtest.yaml

Yaratılan deployment içerisinde request/limit değerleri set edilmiştir. Request/Limit değerleri deployment içerisinde verilebilir, veya limitranges ile otomatik olarak atanabilir.

Administration > Resource Quotas > Create Resource Quotas alanından aşağıdaki yaml ile resource quota create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-10/k8s-resources/Resourcequota.yaml

<img width="535" height="528" alt="image" src="https://github.com/user-attachments/assets/167dc330-fae7-4a41-aee6-65a9a996d9e9" />

Request ve Limit değerlerindeki kota kullanımları, Administration > Resourcequotas altından görüntülenebilir.

<img width="1540" height="609" alt="image" src="https://github.com/user-attachments/assets/6b9e88dd-cb6c-41f9-bd43-f7c07e1080f8" />

Workloads > Deployments > loadgenx altına girilerek replica sayısı 2 ye yükseltilir.

<img width="1045" height="520" alt="image" src="https://github.com/user-attachments/assets/4cdea03f-bd67-4795-b4e7-eb2071d37425" />

Request ve Limit değerlerindeki kota kullanımları kontrol edilir. Administration > Resourcequotas

<img width="1499" height="597" alt="image" src="https://github.com/user-attachments/assets/8e668846-5343-4367-aaff-6d21cc64a2f7" />

Workloads > Deployments > loadgenx altına girilerek replica sayısı 3 e yükseltilir. Replika sayısının 3'e çıkamadığı görülür, çünkü bu proje için oluşturulan resource quota izin vermemektedir.

<img width="1005" height="562" alt="image" src="https://github.com/user-attachments/assets/262a1384-cfe4-4729-bfe6-ca0ee4e59c34" />

Home > Events altından ilgili loglar görülebilir.

<img width="1890" height="504" alt="image" src="https://github.com/user-attachments/assets/9e2b6ba8-9b4c-4b2f-9448-3f08e65e9b7e" />

## Horizantal Pod Autoscaler Demo

Resource quotas labı yapıldıysa, Administration > Resource quotas altından yaratılan resource quota delete edilmelidir.

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

(Eğer resourcequota demosu yapıldıysa, alttaki adımdaki create deployment adımı atlanabilir.)
Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-10/k8s-resources/Deployment-loadtest.yaml

Workloads > Deployments > loadgenx içerisinden, deployment'ın 1 replika olarak set edilir.

<img width="1267" height="602" alt="image" src="https://github.com/user-attachments/assets/d47ecefd-cd7d-4f36-b5d5-c2dbfbc99172" />

Workloads > Deployments > loadgenx > Add HorizontalPodAutoscaler'a tıklanır.

<img width="1258" height="585" alt="image" src="https://github.com/user-attachments/assets/7aded34f-61b1-43d9-bdb4-fb71a5cc306c" />

Memory Utilization alanına 70 set edilir ve save edilir.

<img width="1195" height="835" alt="image" src="https://github.com/user-attachments/assets/1927eb64-07a1-41bf-a4ee-8fd2c43f1db0" />

Workloads > Pods > loadgenx > Terminal ile pod'un terminaline bağlanılır.

<img width="1354" height="705" alt="image" src="https://github.com/user-attachments/assets/aa5ae4bd-b4fd-45f9-8e92-53bc508f1004" />

Aşağıdaki komut terminal komut satırında çalıştırılır.
```
curl "http://localhost:8080/mem?mb=120&workers=4&seconds=60"
```

Workloads > Pods kısmından, Pod memory kullanımının arttığı görülebilir.

<img width="1696" height="628" alt="image" src="https://github.com/user-attachments/assets/3ac21ac3-1983-4f9c-bb6c-f13f1ae88b90" />

Bir süre bekledikten sonra yaratılan HorizantalPodAutoscaler'ın replika sayısını otomatik arttırdığı görülebilir.

<img width="1582" height="638" alt="image" src="https://github.com/user-attachments/assets/70297103-e5c4-46e0-9a38-6f64ccf74572" />



