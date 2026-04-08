# OpenShift Deployment Türleri

Bu demoda OpenShift üzerinde farklı deployment stratejilerini deneyeceğiz.

Kullanılan stratejiler:

* Recreate
* Rolling Update
* Blue Green

## Recreate Deployment Stratejisi

Önce mevcut tüm podları durdurur, ardından yeni podları başlatır.

```
strategy:
  type: Recreate
```

**Davranış:**

eski podlar silinir
yeni podlar daha sonra oluşturulur

Kısa süreli kesinti oluşur.

Şu durumlarda kullanılır:

veritabanı şema değişiklikleri
paylaşılan ortak storage alanı çakışmaları
uygulamanın aynı anda iki versiyonunun birlikte çalışamaması

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />


Menüden Workloads > Deployment kısmına tıklanır. Create Deployment > Yaml view kısmına aşağıdaki linkteki yaml dosyasının içeriği yapıştırılıp Deployment create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Deployment-Recreate.yaml

İlgili deployment için service objesi oluşturulur:

Networking > Services > Create service. Aşağıdaki linkteki yaml dosyasının içeriği yapıştırılıp service create edilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Service-Recreate.yaml

<img width="1402" height="628" alt="image" src="https://github.com/user-attachments/assets/23b58107-5c2c-4746-b579-bd79db2ce624" />

Service create edildikten sonra, uygulamayı internete açmak için Route Create edilmelidir.

Networking > Routes > Create Route. Form view'a tıklanarak aşağıdaki şekilde alanlar doldurulur ve Create edilir.

<img width="1290" height="781" alt="image" src="https://github.com/user-attachments/assets/d863db9c-1995-4ba7-b4e2-942ca63542f5" />

<img width="1098" height="502" alt="image" src="https://github.com/user-attachments/assets/8645ecd8-4565-47dd-b2fe-6a47ed4cbcfc" />

<img width="1523" height="798" alt="image" src="https://github.com/user-attachments/assets/50739c95-a225-4f4c-b912-4176ea05383f" />

Route oluştuktan sonra, location kısmındaki adresten route'a erişilebilir.

<img width="1496" height="792" alt="image" src="https://github.com/user-attachments/assets/284e2974-5189-41f7-a4dd-68e43dc3039e" />

<img width="1029" height="518" alt="image" src="https://github.com/user-attachments/assets/1415e2c8-e071-4001-b85b-89f2fafc6909" />

Uygulamanın yeni bir versiyonunun deploy edilmesi için, mevcut deployment güncellenir:

Deployments > webserver-v1 > Yaml > image: kısmı quay.io/emre_celik/webserver-demo:v2 olarak değiştirilir.

<img width="1126" height="802" alt="image" src="https://github.com/user-attachments/assets/18048045-80a0-474e-90e9-48e1d7609c6e" />

Kaydediltikten sonra, Pods sekmesine tıklanır. Tüm podların aynı anda terminating status'de olduğu görülür. Deployment yaml içerisindeki strategy type: Recreate seçili olduğu için tüm podlar kill edilir, yenileri ayağa kaldırılır. Burada kısa süreli uygulama kesintisi yaşanır.

<img width="1297" height="490" alt="image" src="https://github.com/user-attachments/assets/ebd5bb0b-3380-48ab-99c7-6d6e994b6bd5" />

Routes altındaki adresten, yeni versyionun ayağa kalktığı görülebilir.

<img width="935" height="521" alt="image" src="https://github.com/user-attachments/assets/b0cedb1b-791a-4b39-8503-75daab11a5d6" />


## Rolling Update Deployment Stratejisi

Podlar kademeli olarak değiştirilir.

Örnek:

```
strategy:
  type: RollingUpdate
```

**Davranış:**

eski podlar adım adım sonlandırılır
yeni podlar adım adım başlatılır

Çoğu durumda kesinti yaşanmaz.

En yaygın kullanılan stratejidir.

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Eğer önceki demo yapılmış ise, Deployments > webserver-1 deployment'ına tıklanır. Yaml sekmesine tıklanır. Strategy kısmı aşağıdaki şekilde değiştirilir.
Eğer önceki demo yapılmamış ise, veya deployment altında webserver-1 isimli deployment mevcut değil ise, create deployment a tıklanarak aşağıdaki linkteki yaml ile deployment oluşturulabilir.

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Deployment-Rolling.yaml

<img width="1128" height="776" alt="image" src="https://github.com/user-attachments/assets/74c6a27f-65ec-4288-b945-83b2252b5d44" />

Servis ve route objeleri önceki demoda oluşturulmuş ise, mevcut servis ve route objeleri kullanılabilir. Eğer oluşturulmamışlarsa, önceki demodaki servis ve route create etme adımları uygulanmalıdır.

Routes altından uygulamanın versiyonu görüntülenir: Location alanındaki adrese tıklanır.

<img width="1251" height="454" alt="image" src="https://github.com/user-attachments/assets/93fbc4ac-8e29-478e-b25b-00f6923c4f69" />

<img width="984" height="533" alt="image" src="https://github.com/user-attachments/assets/f138b7f0-3f5e-46bc-9ce6-7650be6ea7ed" />


Uygulamanın yeni bir versiyonunun deploy edilmesi için, mevcut deployment güncellenir:

Deployments > webserver-v1 > Yaml > image: kısmı quay.io/emre_celik/webserver-demo:v2 olarak değiştirilir.

<img width="1126" height="802" alt="image" src="https://github.com/user-attachments/assets/18048045-80a0-474e-90e9-48e1d7609c6e" />

Kaydediltikten sonra, Pods sekmesine tıklanır. Recreate den farklı olarak, eski podları tamamen kill etmeden önce, yeni podları ayağa kaldırdığı görülebilir. Böylece uyguılamada herhangi bir kesinti yaratmadan yeni versiyona geçilmiş olur.

<img width="1194" height="645" alt="image" src="https://github.com/user-attachments/assets/67f6d931-1dd5-49c1-a597-d19cd934088d" />

Routes altındaki adresten, yeni versyionun ayağa kalktığı görülebilir.

<img width="935" height="521" alt="image" src="https://github.com/user-attachments/assets/b0cedb1b-791a-4b39-8503-75daab11a5d6" />



## Blue Green Deployment Stratejisi

Aynı anda iki ayrı ortam çalıştırılır.

Blue = mevcut versiyon
Green = yeni versiyon

Geçiş Service selector değiştirilerek yapılır.

**Örnek akış:**

1 yeni versiyon ayrı bir deployment olarak hazırlanır
2 doğrulama yapılır
3 Service label değiştirilir
4 trafik anında yeni versiyona yönlendirilir

**Avantajlar:**

anında geri dönüş yapılabilir
geçiş öncesi güvenli test imkanı sağlar

Production ortamlarında sık kullanılan bir yöntemdir.

Openshift arayüzüne demo kullanıcısı ile login olunur.

https://console-openshift-console.apps.ocp-qua-test.quasys.com.tr/

<img width="677" height="330" alt="image" src="https://github.com/user-attachments/assets/80813ef8-350a-4ded-b979-e2371aa851c2" />

<img width="558" height="444" alt="image" src="https://github.com/user-attachments/assets/aa83b40a-631f-4160-a8ae-93c22024ce27" />

Eğer önceki demolar yapılmış ise, deployment, service ve route objeleri silinmelidir.

Deployments > webserver-v1 > Delete Deployment
NEtworking > Services > webserver-v1 > Delete Service
Networking > Routes > Delete Route

Aşağıdaki linkte bulunan yaml içeriği ile yeni deployment oluşturulur. 

Workloads > Deployments > Create Deployment > Yaml view

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Deployment-Blue.yaml

Aşağıdaki linkte bulunan yaml içeriği ile ikinci deployment oluşturulur. 

Workloads > Deployments > Create Deployment > Yaml view

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Deployment-Green.yaml

Aşağıdaki linkte bulunan yaml içeriği ile ilk service oluşturulur.

Networking > Services > Create Service

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Service-Blue.yaml

Aşağıdaki linkte bulunan yaml içeriği ile ikinci service oluşturulur.

Networking > Services > Create Service

https://raw.githubusercontent.com/quasys-tech/Container-k8s-enablement/refs/heads/master/Session-9/Kubernetes-Resources/Service-Green.yaml

Uygulamayı dışarıya expose etmek için, route oluşturulur:

Networking > Routes > Create Route

<img width="1168" height="820" alt="image" src="https://github.com/user-attachments/assets/442f16ca-64e8-443d-ae76-eb72106e4968" />

<img width="1597" height="671" alt="image" src="https://github.com/user-attachments/assets/98c9dc26-4137-4aa4-9dda-aaaec11bb46c" />

<img width="1599" height="840" alt="image" src="https://github.com/user-attachments/assets/d5c3bb5d-36da-4f94-9aad-dc7e6d99ca61" />

Networking > Routes > Location kısmındaki adres ile uygulamaya gidilebilir.

<img width="1208" height="449" alt="image" src="https://github.com/user-attachments/assets/4f09a38e-54d6-4158-b152-d4acc58d6ab0" />

<img width="1064" height="493" alt="image" src="https://github.com/user-attachments/assets/02271104-712a-4311-8346-6294fc2d69e1" />

Şuan uygulamanın 2 versiyonu da deployed ve çalışır durumda. Workloads > Pods kısmından çalışan tüm podlar görüntülenebilir. Fakat route ile erişilen uygulama v3 uygulaması.

<img width="1442" height="819" alt="image" src="https://github.com/user-attachments/assets/e73034cb-f7c2-4a4d-928a-4cce2b72704f" />

Şimdi, podlarda bir değişiklik yapmadan, sadece route tanımındaki service tanımı değiştirilerek blue-green switch yapılır.

Networking > Routes > Edit Route > Service : webserver-v1-green , Target Port: 8080

<img width="1302" height="773" alt="image" src="https://github.com/user-attachments/assets/972a48b7-ddcb-40e2-a56b-26c2e720e5fd" />

Networking > Routes > Location kısmındaki adres ile uygulamaya gidilebilir. Artık mavi sayfa yerine v4 olan yeşil sayfanın açıldığı görülecektir.

<img width="1033" height="510" alt="image" src="https://github.com/user-attachments/assets/1711bf11-1b65-48d9-8b45-a267f259efe6" />

