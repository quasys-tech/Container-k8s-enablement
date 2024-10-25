# OPENSHIFT DEMO

Openshift Address: https://console-openshift-console.apps.ocpquademo.quasys.com.tr

## Login Openshift

![image](https://github.com/user-attachments/assets/25f4e6fe-798b-4d7c-b6fa-9e8980ca7cd6)

Openshift'e login için "Demo-Login" butonu ve sonrasında username-password ile giriş yapılır.

## Openshift Console

Openshift'e login olduktan sonra, Administrator view a geçiş yapılır.


![image](https://github.com/user-attachments/assets/c36563d9-48f7-4a42-8615-f49b1bd21d09)


Demo'nun yapılacağı namespace'e geçmek için, Home > Projects > demo-namespace* seçilir

![image](https://github.com/user-attachments/assets/fb442c98-fd01-4bab-9c73-5619aa6b22dc)
![image](https://github.com/user-attachments/assets/49182d4a-c294-43e8-9b81-5a1a69bce97d)


## Openshift Konsol Bileşenleri

### Projects/Namespaces

Kubernetes deki namespace objesi openshift de project olarak geçmektedir.
Home > Projects kısmından mevcut namespace'ler görüntülenebilir. Kullanıcılar sadece kendi namespacelerinde yetkili olduklarından, sadece 1 namespace listelenmektedir. 

![image](https://github.com/user-attachments/assets/ae24abb5-74e2-4969-8d3b-3e90941b4405)

## Workloads

Workloads menüsü altından pod, deployment, statefulset, secrets, configmap, daemonset gibi openshift-kubernetes resourceları görüntülenebilir/yaratılabilir/değiştirilebilir.

![image](https://github.com/user-attachments/assets/1e6a017b-6544-4c0a-b162-4bfc8b6a0807)

## Networking

Networking menüsü altından service, ingress, route gibi openshift-kubernetes resourceları görüntülenebilir/yaratılabilir/değiştirilebilir.

![image](https://github.com/user-attachments/assets/2618171e-2134-47f9-b286-945e66aecbc8)

## Storage

Storage menüsü altından, statefull uygulamaların persistentvolume, persistentvolumeclaim gibi bileşenler sayesinde disk attach işlemleri sağlanır. 

![image](https://github.com/user-attachments/assets/26638ea6-6775-436f-97ec-bfce8c22fad2)


## Cli Terminal

"kubectl" ve "oc" komut satırlarını kullanmak için, openshift web-terminaline sağ üstte bulunan simgeye tıklayarak erişebilirsiniz.

![image](https://github.com/user-attachments/assets/4f371167-52a1-4862-bf5b-94ca1969a29e)

Açılan terminalde, demo-namespace* ile başlayan proje seçilir ve start edilir.

![image](https://github.com/user-attachments/assets/ab6c73ee-67e7-47dc-8ed0-17e260848c57)

Web terminal açıldıktan sonra "kubectl" ve "oc" komutları kullanılabilir.

![image](https://github.com/user-attachments/assets/e4fbaefa-d574-453d-9253-6200392d820f)

## Demo Uygulama Deploy

Demo sırasında openshift'e deploy edilecek uygulama, deployment tipinde bir kubernetes resource'u kullanılarak deploy edilecektir. Deployment, belirli bir sayıda pod’un Kubernetes kümesi üzerinde koşmasını sağlayan ve bu pod'ları yönetmek için kullanılan bir mekanizmadır.

Konsol üzerinde Workloads > Deployments a geçilir. Gelen ekranda "Create Deployment" a tıklanır.

![image](https://github.com/user-attachments/assets/5ef3f314-de83-4dca-92c7-54f561435613)

YAML view'a geçilerek, https://raw.githubusercontent.com/quasys-tech/container-k8s-101/refs/heads/main/week-2/Kubernetes-Resources/k8s-intro-nginx-deployment.yml linkinde bulunan yaml içeriği ilgili alana yapıştırılır.

![image](https://github.com/user-attachments/assets/e88e8d45-8d71-437b-a401-845f972ddfd0)


Workloads > Pods menüsünden veya Web Terminal aracılığı ile POD'ların running durumda olup olmadıkları kontrol edilir. 

Web terminal üzerinden mevcut podları görmek için "kubectl get pods" komutu kullanılabilir.


![image](https://github.com/user-attachments/assets/53f8cf2e-6189-431d-aa25-0c07b439b570)

## POD

Pod, Kubernetes ortamında yönetilebilen en küçük ve basit birimdir. Bir pod, bir veya daha fazla konteyneri içerir ve bu konteynerler aynı ağ ve depolama kaynaklarını paylaşır.

Pod'un detaylarına, Workloads > Pods ekranından podun ismine tıklanarak ulaşılabilir. Üst tarafta seçili olan Project: demo-namespace* podların bulunduğu namespace/projeyi bildirir. Podlar namespace bazlı objelerdir, her podun ait olduğu bir namespace/projesi bulunur.

Details Tab'ında Pod ile ilgili genel bilgiler bulunur. Pod'un adı, Statüsü, Pod IP adresi, üzerinde çalıştığı Openshift Node'un IP adresi vs.

![image](https://github.com/user-attachments/assets/b8650f82-46bc-4b01-b6b4-55cf01313954)


Metrics tabında pod ile ilgili performans metriklerine ve kaynak kullanım detaylarına ulaşılabilir.

![image](https://github.com/user-attachments/assets/9698a09f-c599-4f8b-91a8-51af94eea13a)


YAML tabından çalışan pod'un yaml dosyasına ulaşılabilir. Mevcut konfigürasyon ile ilgili bilgiler ve statü bilgileri de yaml da bulunur.


![image](https://github.com/user-attachments/assets/20feb5b9-7f68-4be8-bfac-78aaefc0d134)


Environment Tabında, pod'un kullandığı environment variable lar var ise bunlar ile ilgili detaylar görülebilir.


![image](https://github.com/user-attachments/assets/ec887556-3a04-44e5-a06c-6813e34766f5)


Logs tabından, çalışan podun STDOUT a gönderdiği tüm çıktılar izlenebilir. Pod restart olursa bu loglar da kaybolur.
Eğer Pod içerisinde birden fazla container var ise, containerlar seçilerek de ilgili container'a ait loglara erişilebilir.


![image](https://github.com/user-attachments/assets/4f105a79-1e2c-4790-a561-59178babc92d)


Terminal Tab'ından çalışan pod'un komut satırına bağlanılabilir.

![image](https://github.com/user-attachments/assets/e8ead9e3-de98-46ca-9ad2-d91488729665)


Pod'un terminalinde "hostname" "ps -ef" gibi komutlar çalıştırılarak çıktıları incelenebilir.


![image](https://github.com/user-attachments/assets/e0ff25c8-1a4f-4966-bb94-ec2305599bbb)

Komut satırından pod ile ilgili bilgilere ulaşmak için aşağıdaki komutlar kullanılabilir.

      kubectl get pods
      kubectl describe pod <pod-adı>

![image](https://github.com/user-attachments/assets/fce36793-f0aa-4e5d-8b5e-3fb228d60548)

Pod'un loglarına ulaşmak için;

      kubectl logs <pod-adı>

![image](https://github.com/user-attachments/assets/baf2e5d7-ef7d-4b09-a2a9-65d60f023710)


## DEPLOYMENT

Demo Uygulama Deploy adımında yaratılan deployment detaylarını görmek için, Konsolda Workloads > Deployments menüsüne geçilir. Deploymentların listelendiği bu ekranda, Üst tarafta Project: demo-project* ile halihazırda seçili olan namespace/proje görülebilir. Deployment da namespace/project bazlı bir kubernetes nesnesidir.


![image](https://github.com/user-attachments/assets/67e1aeab-a6f8-493a-886c-f4d69983f22a)


Deployments ekranında, k8s-intro-nginx e tıklanarak deployment detayları görüntülenebilir.

Bu ekranda, deployment replica sayısı, Deployment Update Strategy (yeni versiyon çıktığında bu versiyonun nasıl uygulanacağı ile ilgili bilgi), Pod label, Node Selector, Toleration gibi bilgiler bulunur.

![image](https://github.com/user-attachments/assets/885a3736-e26d-4a3b-aded-d4479d11b8c3)


Replicasets tabında, deployment'a bağlı replicaset görüntülenebilir.


![image](https://github.com/user-attachments/assets/8567b4cb-2764-48c3-a006-e9854955dc1e)


Pods tabında, deployment tarafından yaratılmış olan podlar görüntülenebilir.


![image](https://github.com/user-attachments/assets/5b6d8ece-a4ff-4a82-a9f1-4eaae077086d)


Deployment detaylarına terminal üzerinden ulaşmak için, aşağıdaki komutlar kullanılabilir.

      kubectl get deployment
      kubectl describe deployment <deployment-adı>


![image](https://github.com/user-attachments/assets/80f7a5f4-14c1-482d-9ebb-abfe6385c212)


Aşağıdaki komut ile deployment'ın yaml çıktısı alınabilir.


      kubectl get deployment <deployment-adı> -o yaml


![image](https://github.com/user-attachments/assets/35ffe8fe-ac4f-4de5-899e-20e214659b6a)


## Secrets

Kubernetes Secrets, hassas verileri (şifreler, API anahtarları, tokenler, sertifikalar gibi) depolamak ve yönetmek için kullanılan bir Kubernetes nesnesidir. Kubernetes ortamında uygulamaların bu hassas verilere erişmesi gerektiğinde, bu verileri doğrudan pod’lar içerisine enjekte etmenin yollarını sunar.

Workloads > Secrets menüsünden seçili proje/namespace altındaki secret'lar görüntülenebilir.


![image](https://github.com/user-attachments/assets/fa265f67-69fb-41fa-a391-ae8fe087be23)


Yeni secret oluşturmak için, sağ üstte bulunan Create > Key/Value Secret seçilir.


![image](https://github.com/user-attachments/assets/4621a9e3-2aae-40b6-852b-ccb998d286fe)


İlgili alanlar doldurularak secret Create edilir.


![image](https://github.com/user-attachments/assets/fc9af64a-faec-483d-8b01-bd5619a21524)


Oluşturulan secret objesinin, YAML tabına geçilerek, secret detayları görüntülenebilir. Burada key-value olarak girdiğimiz değerlerde sadece key value'sının clear text olarak yazıldığı value kısmının değiştirildiği görülmektedir. Kubernetes burada base64 encoding kullanır. 

![image](https://github.com/user-attachments/assets/900dba67-771f-423f-9400-1332aafe359b)


Base64 decoding ile bu data kolayca açığa çıkarılabilir.

Secret Yaml da bulunan encoded değer bir dosyaya yazılarak aşağıdaki şekilde decode edilebilir.


![image](https://github.com/user-attachments/assets/77d77816-cf91-4567-bd69-9ebec30db6d6)


Yaml dosyası ile de secret oluşturulabilir. Openshift konsolda sağ üstte yer alan "+" tuşuna basılarak, aşağıdaki linkteki yaml dosyası buraya yapıştırılır ve create edilir.

https://raw.githubusercontent.com/quasys-tech/container-k8s-101/refs/heads/main/week-2/Kubernetes-Resources/k8s-intro-secret.yml

![image](https://github.com/user-attachments/assets/4cc6c003-8a9b-4290-86a5-8d0c419f62cf)


![image](https://github.com/user-attachments/assets/5c9a7d38-7f4d-479b-bd94-8f187cd37278)


Oluşturulan secret'ı daha önce oluşturduğumuz deployment'a attach etmek için, menüden Workloads > Deployments a geçilir. "k8s-intro-nginx" deployment içerisine girilir. spec.containers altında aşağıdaki gibi env: ile başlayan 6 satırlık blok eklenir. 

Buna alternatif olarak da mevcut deployment delete edilerek, aşağıdaki linkte bulunan içerisine env eklenmiş deployment dosyası da Create Deployment > YAML view içerisine yapıştırılarak secret attach edilmiş deployment yaratılabilir.

https://raw.githubusercontent.com/quasys-tech/container-k8s-101/refs/heads/main/week-2/Kubernetes-Resources/k8s-nginx-deployment-with-secret.yml

          spec:
            containers:
              - name: k8s-intro-nginx
                image: quay.io/emre_celik/k8s-intro-nginx
                ports:
                  - containerPort: 80
                    protocol: TCP
                env:
                  - name: DEMO_SECRET
                    valueFrom:
                      secretKeyRef:
                        name: k8s-demo-secret
                        key: demosecret
                resources: {}
                terminationMessagePath: /dev/termination-log
                terminationMessagePolicy: File
                imagePullPolicy: Always


![image](https://github.com/user-attachments/assets/7777afca-f0b7-4487-8d7e-979f8e7a16c4)


Workloads > Pods menüsünden k8s-intro-nginx podlarından herhangi birine girilip, Terminal tabına geçilir. Environment Variable olarak attach edilen secret burada görüntülenebilir.

      echo $DEMO_SECRET

![image](https://github.com/user-attachments/assets/6ae5f95d-ca82-455a-80d4-398591165c4b)

## SERVICE

Kubernetes'te çalışan pod'lar arasındaki ağ trafiğini yöneten ve bir grup pod'u bir araya getiren soyut bir ağ kaynağıdır. Servis, pod'ların değişken IP adreslerine sahip olmasına rağmen onlara tutarlı bir Servis IP adresi ve DNS adı sağlar, böylece uygulamalar arasında sabit bir iletişim noktası oluşturur. Kubernetes cluster'ında genellikle farklı bileşenlerin birbiriyle haberleşmesini sağlamak amacıyla kullanılır.

Networking > Services menüsünden "Create Service" tıklanarak aşağıdaki yaml içeriği yapıştırılarak demo servis oluşturulabilir.

https://github.com/quasys-tech/container-k8s-101/blob/main/week-2/Kubernetes-Resources/k8s-intro-nginx-service.yml

![image](https://github.com/user-attachments/assets/0d2080f6-bb42-458d-bc7f-dd6aaa12b5b8)

![image](https://github.com/user-attachments/assets/4b0e6bde-3476-4e43-a0ba-26cc2193d9c9)

Workloads > Pods menüsünden k8s-intro-nginx podlarından herhangi birisine girilerek, mevcut podlardaki label bilgilerine ulaşılabilir.

Servisi oluştururken de yaml içerisinde selector alanında bu label bilgileri verilir. Servis trafiği hangi podlara yönelteceğini labellar sayesinde belirler.

![image](https://github.com/user-attachments/assets/15aa3383-64c9-46ff-9091-4e28c335caab)

Networking > Services menüsünden, oluşturulan k8s-intro-nginx-service servisine girildiğinde,

Details: servis ile ilgili genel bilgiler, dns adı, dinlediği port bilgisi, pod'a trafiği ileteceği port bilgisi, pod selector bilgilerine ulaşılabilir.
YAML: Servisin yaml haline ulaşılabilir.
Pods: Servisin hizmet ettiği podların listesine ulaşılabilir.

![image](https://github.com/user-attachments/assets/e3279f3a-19e2-4cf5-825a-f8c8f287ebfe)

![image](https://github.com/user-attachments/assets/96178d96-8305-45b0-b45e-2813044f2116)

Networking > Services menüsünden, oluşturulan k8s-intro-nginx-service servisine girilir. Hostname alanındaki DNS adı kopyalanır "k8s-intro-nginx-service.demo-namespace3.svc.cluster.local".

![image](https://github.com/user-attachments/assets/5171c763-a945-4464-9471-167bdc2e944c)

Farklı uygulamalar Kubernetes içerisinde birbirleriyle service objeleri üzerinden haberleşirler. HEr bir servisin Kubernetes içerisindeki DNS de tutulan bir DNS kaydı vardır. Bu standard da servis-adı.namespace.svc.cluster.local şeklindedir.

WOrkloads > Pods menüsünden herhangi bir k8s-intro-nginx-* poduna girilir ve Terminal tabına geçilir. Nslookup komutuyla pod içerisinden servis DNS inin çözülebildiği görülür. Farklı namespace de bulunan uygulamalar da bu DNS kaydı ile servise erişebilir.


![image](https://github.com/user-attachments/assets/f5a5f715-da43-43a2-bc26-e9821ebc6afa)

Pod terminalinden, aşağıdaki komut ile servise curl isteği atıldığında cevap alınabildiği görülür.

      curl k8s-intro-nginx-service.demo-namespace3.svc.cluster.local

![image](https://github.com/user-attachments/assets/4e1e4bea-624d-4407-9c58-8dbc695b8a67)


Workloads > Pods menüsünden herhangi bir k8s-intro-nginx-* poduna girilerek, ip bilgisi kopyalanır.

Pod terminalinden aynı istek servis yerine pod ip adresine yapıldığında, aynı cevabın döndüğü görülür.

![image](https://github.com/user-attachments/assets/3495d0bb-a583-41b8-91f3-4d17c17e3153)

![image](https://github.com/user-attachments/assets/ecff0bfc-97a3-4b05-9125-e38366d6a372)



## ROUTE - Uygulamanın Openshift Dışına Açılması

OpenShift Route, dış dünyadan Kubernetes veya OpenShift cluster'ında çalışan bir servise erişim sağlamak için kullanılan bir kaynak türüdür. Route, uygulamalarınıza dışarıdan HTTP veya HTTPS trafiğini yönlendiren ve uygulamanın dış dünyaya açılmasını sağlayan bir yol tanımlar. OpenShift, Route'ları kullanarak dış dünyadan gelen istekleri belirli bir servise ve dolayısıyla arka plandaki pod'lara yönlendirir.

Networking > Routes menüsünden Route ekranına geçilebilir.

Yeni bir Route yaratmak için "Create Route" butonuna basılır.


![image](https://github.com/user-attachments/assets/1cb980c0-b898-4131-9f6c-3686519960b5)

Aşağıdaki bilgilerle yeni bir route create edilir.

Name: k8s-intro
Hostname: Boş bırakılır
Service: k8s-intro-nginx-service seçilir
Target Port: 80 -> 80 TCP
Secure Route kutucuğu işaretlenir.
      TLS Termination: Edge
      Insecure Traffic: None


![image](https://github.com/user-attachments/assets/14c2b455-d08f-41ae-8666-36b85d73e895)

![image](https://github.com/user-attachments/assets/6cd49637-bd93-4897-8a5b-7a0592987c64)

Oluşturulan Route içerisine girilip incelendiğinde, Details kısmında Route ile ilgili detaylar görülebilir.

Openshift uygulamaları expose ederken kendi wildcard DNS i üzerinden expose etme imkanı tanır. Böylece yeni bir DNS kaydı veya LB tanımı yapılmadan uygulama openshift üzerinden dışarıya açılabilir.

Burada "*.apps.ocpquademo.quasys.com.tr" için bir wildcard DNS kaydı tutulur ve oluşturulan route'lar bu suffix ile oluşturulur. Örneğin https://k8s-intro-demo-namespace3.apps.ocpquademo.quasys.com.tr/

Alternatif olarak, kendi DNS kaydınızı ve LB tanımınızı yaparak da custom bir adres için Route oluşturabilirsiniz. (Örneğin https://k8s-intro.company.com.tr ) Demo sırasında kolay olması adına openshift'in wildcard adresi tercih edilmiştir.

"Location" kısmında bulunan link aracılığı ile uygulamaya erişim sağlanabilir.


![image](https://github.com/user-attachments/assets/e607b566-5cbc-4916-9b24-395a462c32ed)

![image](https://github.com/user-attachments/assets/82283be2-9571-4af3-9236-0c3bf1a158f5)



