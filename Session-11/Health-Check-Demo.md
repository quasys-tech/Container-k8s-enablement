## Readiness Probe Demo

Readiness probe'lar bir pod'un sağlıklı şekilde ayağa kalkıp kalkmadığını kontrol etmek için kullanılır. Readiness probe'lar pod restart etmezler, sadece monitor ederler.
İstenilen koşul sağlanmıyorsa, podun running statusune geçmesini engeller.

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/Deployment-without-readiness.yaml

<img width="1156" height="481" alt="image" src="https://github.com/user-attachments/assets/a2655f51-1fed-4a52-81c8-aea08b8e1d07" />

Workloads > Pod altından Podların Ready 1/1 olduğu teyid edilir:

<img width="1156" height="481" alt="image" src="https://github.com/user-attachments/assets/0696dc45-e891-4302-9db8-251956ea0243" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/Deployment-readiness.yaml

Ayağa kalkan podlar kontrol edilir: 
Workloads > Pods:
Podların ready kolonlarının 0/1 olduğu görülür. 60 saniye sonunda Podların 1/1 olduğu görülür.

<img width="1180" height="416" alt="image" src="https://github.com/user-attachments/assets/86909376-7d07-425b-a15c-8a5802f9eff6" />

Workloads > Deployments > webserver-v1 > Yaml içerisine girilip, "readinessProbe" satırı bulunur.
Eklenen readiness probe konfigürasyonu sebebiyle, pod ayağa kalktıktan sonra 5 sn bekleyip readiness probe 5 saniyede bir readiness probe içerisinde bulunan healthcheck endpointine istek yollar.
İlk 60 saniye, bu healthcheck endpoint ayakta olmadığı için, Pod 0/1 olarak görülür ve servis bu poda trafik iletmez. Böylece pod ayağa kalkmadan trafik alması engellenmiş olur.

<img width="1043" height="763" alt="image" src="https://github.com/user-attachments/assets/1a3aa317-2689-4625-aaec-206a8df55c49" />


## Liveness Probe Demo

Readiness probe demosunda yaratılan Deployment'lar silinir. Workloads > Deployments > Delete Deployment.

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/Deployment-liveness.yaml

<img width="1156" height="481" alt="image" src="https://github.com/user-attachments/assets/a2655f51-1fed-4a52-81c8-aea08b8e1d07" />

Readiness probe demosunda, ilk 60 saniye podların Ready duruma geçmediğini görmüştük. Burada herhangi bir readiness probe eklenmediği için podlar 1/1 Ready olarak gözükürler.

<img width="1090" height="479" alt="image" src="https://github.com/user-attachments/assets/2b13d913-c1aa-4f39-a450-c15ff67d1f46" />

Bir süre beklendikten sonra, Workloads > Pods ekranında Restart sayılarının arttığı görülebilir. Webserver 60 saniye bekleme süresinden sonra start olduğu için, liveness probe kontrolleri bu süre içerisinde podu restart etmektedir.
```
        livenessProbe:
          tcpSocket:
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 2
          failureThreshold: 3
```

<img width="1118" height="554" alt="image" src="https://github.com/user-attachments/assets/d70367e4-974b-4320-b664-b1cf7f35a660" />

Workloads > Pods > webserver-liveness > Events altından liveness probe event'leri görülebilir.

<img width="1085" height="440" alt="image" src="https://github.com/user-attachments/assets/329f9411-65ac-44f6-b846-feb861b75b35" />

Liveness Probe'un podu restartlamasını engellemek için liveness probe düzenlenir. Şimdiki durumda 5 saniye bekleyip daha sonra healthcheck işlemlerine başlamaktadır. 

Workloads > Deployments > webserver-liveness > Yaml içerisinden, "initialDelaySeconds" değeri 90 olarak değiştirilir.

<img width="1051" height="611" alt="image" src="https://github.com/user-attachments/assets/e2fbc5b6-ee76-42af-b376-45a6f8f29688" />


Bir süre bekledikten sonra, Workloads > Pods altından podların artık restart olmadığı teyid edilir.

<img width="1083" height="477" alt="image" src="https://github.com/user-attachments/assets/b74a64eb-0502-4019-89c3-1b23596f09b8" />



## Persistent Volume Demo

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/Deployment-pvc-novol.yaml

Workloads > Pods > pvc-demo > Terminal e girilip Pod'un komut satırına bağlanılır.

Aşağıdaki komutlar terminalde çalıştırılıp, /opt dizini altında dosya ve klasörler oluşturulur.

```
cd /opt
mkdir testfolder
echo "testcontent" > testfile
ls
cat testfile
```

<img width="995" height="546" alt="image" src="https://github.com/user-attachments/assets/65471710-e2bb-4dd1-a6e0-7eda5c4dfed8" />

Workloads > Pods > pvc-demo podu Delete edilir. Yeni oluşturulan Pod'un komut satırına bağlanılır. (Workloads > Pods > pvc-demo > Terminal

opt dizini altında ls komutuyla, önceki adımda oluşturulan dosyaların silindiği görülebilir.

```
ls /opt
```

<img width="1046" height="505" alt="image" src="https://github.com/user-attachments/assets/af3da14d-0a35-4757-a851-8c0a9b36ba3b" />

Podlar, defaultta stateless olarak çalışır. Pod çalışırken oluşan tüm dosyalar, klasörler pod restartı sonrası silinir.

Bazı uygulamaların state tutma ihtiyacı olabilmektedir. Bunlar genellikle statefull uygulamalar olarak isimlendirilir.

Pod içerisinde silinmesi istenmeyen datalar için, persistentvolumeclaim oluşturulup kullanılabilir.

Storage > PersistentVolumeClaims > Create PersistentVolumeClaim > Edit Yaml altından aşağıdaki yaml ile PersistentVolumeClaim create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/pvc.yaml

Workloads > Deployments altından, pvc-demo deployment delete edilir. (Pod'un terminate olması gerektiği için delete işlemi biraz zaman alabilir.)

Workloads > Deployments > Create Deployment . Aşağıdaki linkte bulunan yaml dosyası ile deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-11/kubernetes-resources/deployment-with-pvc.yaml

Deployment içerisinde bulunan, volumeMounts ve volume konfigürasyonları sayesinde, oluşturulan PersistentVolumeClaim deployment tarafından oluşturulacak podların /opt dizinine bağlanacak.
/opt dizinine yazılan dosyalar artık PersistentVolumeClaim üzerinde tutulacak. Böylece bu dosyalar kalıcı olarak saklanabilecek.

```
        volumeMounts:
        - name: storage
          mountPath: /opt  #PersistentVolumeClaim'in Pod üzerinde hangi path'e mount edileceği bilgisi.
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: pvc-demo # Pod'a bağlanacak olan PersistentVolumeClaim ismi. Önceki adımda oluşturduğumuz PersistentVolumeClaim.
```

Workloads > Pods > pvc-demo > Terminal e girilip Pod'un komut satırına bağlanılır.

Aşağıdaki komutlar terminalde çalıştırılıp, /opt dizini altında dosya ve klasörler oluşturulur.

```
cd /opt
mkdir testfolder
echo "testcontent" > testfile
ls
cat testfile
```

<img width="995" height="546" alt="image" src="https://github.com/user-attachments/assets/65471710-e2bb-4dd1-a6e0-7eda5c4dfed8" />

Workloads > Pods > pvc-demo podu Delete edilir. Yeni oluşturulan Pod'un komut satırına bağlanılır. (Workloads > Pods > pvc-demo > Terminal

opt dizini altında ls komutuyla, önceki adımda oluşturulan dosyaların silinmediği görülebilir.

```
ls /opt
```

<img width="1025" height="534" alt="image" src="https://github.com/user-attachments/assets/0dcc3245-5ad6-4120-8b34-fd9a39dc8704" />




