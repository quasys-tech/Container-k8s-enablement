Container Sec 101 – Prisma Cloud Demo Rehberi

Bu doküman, OpenShift üzerinde oluşturulan demo-vulnerabilities namespace'i içerisindeki kasıtlı güvenlik yanlış yapılandırmalarının Prisma Cloud / Twistlock Console üzerinden nasıl inceleneceğini anlatır.

Amaç: Katılımcıların environment visibility, misconfiguration/compliance, RBAC riski, container runtime davranışı ve incident detection akışlarını Prisma Cloud üzerinden görmesi.

1. Demo Ortamı

OpenShift namespace:

demo-vulnerabilities

Prisma Collection:

training-demo-vulnerabilities

Katılımcı kullanıcı rolü:

DevSecOps User

Katılımcı permission yapısı:

Custom collections
└── training-demo-vulnerabilities


---

# 2. OpenShift Üzerinde Oluşturulan Demo Nesneleri

Demo namespace'i içerisinde aşağıdaki workload ve güvenlik yanlış yapılandırmaları bulunmaktadır.

| Workload / Nesne | Kasıtlı güvenlik problemi | Eğitimde anlatılacak risk |
|---|---|---|
| `privileged-app` | `privileged: true` | Container isolation ciddi şekilde zayıflar |
| `hostnetwork-app` | `hostNetwork: true` | Pod, node network namespace'ini paylaşır |
| `hostpath-app` | Host `/etc` dizini `hostPath` olarak mount edilir | Host filesystem exposure |
| `root-cap-app` | `runAsUser: 0`, `SYS_ADMIN`, `NET_ADMIN` | Root + excessive Linux capabilities |
| `secret-env-app` | Kubernetes Secret environment variable olarak kullanılır | Secret exposure / insecure secret handling |
| `clusteradmin-app` | `clusteradmin-sa` kullanır | Uygulamanın cluster-wide yetkiye sahip olması |
| `clusteradmin-sa` | `cluster-admin` ClusterRoleBinding | Least privilege ihlali |
| `vulnerable-sa` | `privileged` SCC kullanabilir | OpenShift admission security kontrolünün gevşetilmesi |
| `exposed-app` | `NodePort` Service | Gereksiz external attack surface |
| `victim-web` | Runtime demo hedefi | Kontrollü port scan hedefi |
| `attacker-simulator` | Runtime anomalisi üretir | Runtime alert / incident demosu |
| Namespace genelinde | NetworkPolicy bulunmuyor | East-west erişimin gereğinden fazla açık olması |

OpenShift Login kontrol:

Toplantıda belirtilen console ve user bilgileri ile cluster'a erişim sağlanır.   
<img width="1318" height="757" alt="image" src="https://github.com/user-attachments/assets/a5fd9bdb-4a04-40ae-b7c6-e47ffdb32f86" />

İlgili cluster'da demo-vulnerabilities namespace'inde view yetkisi ile çalışan podlar incelenebilir.   
<img width="1851" height="1012" alt="image" src="https://github.com/user-attachments/assets/c9c24fec-0909-402a-99f3-9dc4b3126ff3" />

İstenirse oc login komutu çalıştırılarak da podlar incelenebilir.

```bash
[quasys@ocp-bastion security-preps]$ oc get pods -n demo-vulnerabilities
NAME                                        READY   STATUS      RESTARTS   AGE
attacker-simulator-7b94c55dc5-dhxnr         1/1     Running     0          59m
clusteradmin-app-65877d8766-cx8jb           1/1     Running     0          98m
hostnetwork-app-86485c4588-w28gk            1/1     Running     0          100m
hostpath-app-749ff78ddc-9t9fb               1/1     Running     0          99m
postgresql-6fd8f9947d-fpkvp                 1/1     Running     0          106m
privileged-app-769d9dd59b-f5trl             1/1     Running     0          100m
rails-postgresql-example-1-build            0/1     Completed   0          106m
rails-postgresql-example-7f84bc97fb-qsxh2   1/1     Running     0          103m
root-cap-app-6c67745f69-29xpn               1/1     Running     0          99m
secret-env-app-6cf5966498-kxx4f             1/1     Running     0          99m
victim-web-779c4f8487-f5b9h                 1/1     Running     0          71m
[quasys@ocp-bastion security-preps]$
```


---

# 3. Prisma Cloud Radar

## 3.1 Radar Nedir?

Radar, Prisma Cloud'un ortam içerisindeki container, image, host ve network ilişkilerini görselleştirdiği bölümdür.

Demo sırasında ilk olarak:

```text
Radars
└── Containers
```

ekranına gidilir.

Namespace filtresi:

```text
demo-vulnerabilities
```

olarak seçilir.

<img width="1477" height="810" alt="image" src="https://github.com/user-attachments/assets/e4f17a4c-2b92-48cb-ab42-07af1e5a21d1" />

---

## 3.2 Radar'da Container Gruplaması

Radar her pod'u ayrı bir kutu olarak göstermeyebilir.

Aynı image'ı kullanan birden fazla container tek bir node altında gruplanabilir.

Örneğin demo ortamındaki aşağıdaki workload'lar aynı UBI Minimal image'ını kullanabilir:

```text
privileged-app
hostnetwork-app
hostpath-app
root-cap-app
secret-env-app
clusteradmin-app
```

Bu nedenle Radar üzerinde:

```text
ubi-minimal:latest
        6
```

gibi tek bir node görülebilir.

Buradaki sayı, aynı image'ı kullanan çalışan container sayısını ifade eder.

---


## 3.3 Radar – Color By

Radar ekranındaki `Color by` seçeneği ile görünüm farklı risk türlerine göre renklendirilebilir.

Örneğin:

```text
Color by: Vulnerabilities
```

seçildiğinde image/container üzerindeki CVE yoğunluğu görsel olarak gösterilir.

```text
Vulnerability
    ↓
Image/package içerisindeki CVE

Compliance / Misconfiguration
    ↓
Container veya Kubernetes nesnesinin yanlış yapılandırılması
```
<img width="1870" height="967" alt="image" src="https://github.com/user-attachments/assets/245ac6de-9da3-4578-a1be-be3378b0d21e" />

---

# 4. Monitor → Compliance

Demo içerisindeki kasıtlı security configuration hatalarının asıl inceleneceği bölümlerden biri:

```text
Monitor
└── Compliance
```

Burada mümkünse collection veya namespace filtresi:

```text
training-demo-vulnerabilities
```

veya:

```text
demo-vulnerabilities
```

olarak seçilir.

<img width="1876" height="985" alt="image" src="https://github.com/user-attachments/assets/d8f13d08-02f8-461f-9e23-76ac21b52136" />


---

## 4.1 Privileged Container

OpenShift workload:

```text
privileged-app
```

Kasıtlı configuration:

```yaml
securityContext:
  privileged: true
```

Riskler:

- Container normal isolation sınırlarının dışına çıkar.
- Host kaynaklarına erişim riski artar.
- Bir application compromise olayının etkisi büyüyebilir.
- OpenShift'te normalde SCC bu davranışı engelleyebilir.

Prisma içerisinde `privileged-app` veya ilgili container/image filtrelenerek compliance sonucu incelenir.

<img width="1698" height="471" alt="image" src="https://github.com/user-attachments/assets/3206feb6-c898-4350-8e75-b92a435980e5" />   
<img width="1695" height="960" alt="image" src="https://github.com/user-attachments/assets/b1bd23ee-894a-4a4b-af00-1adbdeaab76b" />



### Remediation

```yaml
securityContext:
  privileged: false
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

---

## 4.2 Host Network

OpenShift workload:

```text
hostnetwork-app
```

Kasıtlı configuration:

```yaml
hostNetwork: true
```

Normal pod:

```text
Container
   ↓
Pod Network Namespace
   ↓
OVN / CNI
   ↓
Node Network
```

`hostNetwork: true`:

```text
Container
   ↓
Node Network Namespace
```

Riskler:

- Pod kendi network namespace izolasyonunu kaybeder.
- Node'un network stack'ine daha yakın hale gelir.
- Gereksiz host network kullanımı attack surface'i artırır.

<img width="1843" height="501" alt="image" src="https://github.com/user-attachments/assets/f2c4d57b-7a68-4c17-94b4-f422549611b5" />

<img width="1707" height="986" alt="image" src="https://github.com/user-attachments/assets/2a7ffa67-15b3-4e11-8180-70bed3223e9e" />

### Remediation

```yaml
hostNetwork: false
```

veya alan tamamen kaldırılır.

---

## 4.3 HostPath Mount

OpenShift workload:

```text
hostpath-app
```

Kasıtlı configuration:

```yaml
volumes:
- name: host-data
  hostPath:
    path: /etc
```

Container içerisinde:

```text
/host-data
    ↓
Node /etc
```

Riskler:

- Container node filesystem'i hakkında bilgi elde edebilir.
- Read-write mount kullanılırsa host üzerinde değişiklik yapılabilir.
- Normal uygulamalarda doğrudan node filesystem erişimi gereksizdir.

<img width="1892" height="538" alt="image" src="https://github.com/user-attachments/assets/8f4bf713-82c0-496b-8992-27145666c915" />

<img width="1497" height="912" alt="image" src="https://github.com/user-attachments/assets/f12e6385-b0c2-4146-9d27-a581c15b23f0" />

### Remediation

Mümkünse:

```text
hostPath
   ↓
PVC / ConfigMap / Secret / emptyDir
```

gibi Kubernetes-native storage mekanizmaları kullanılmalıdır.

---

## 4.4 Root + Linux Capabilities

OpenShift workload:

```text
root-cap-app
```

Kasıtlı configuration:

```yaml
securityContext:
  runAsUser: 0
  allowPrivilegeEscalation: true
  capabilities:
    add:
      - NET_ADMIN
      - SYS_ADMIN
```

Anlatılacak risk:

```text
Root
+
Privilege Escalation
+
SYS_ADMIN
+
NET_ADMIN
```

Container compromise olayının etkisini ciddi şekilde büyütebilir.

Özellikle `SYS_ADMIN`, çok geniş kernel seviyesinde yetkiler sağladığı için normal uygulamalarda verilmemelidir.

<img width="1901" height="542" alt="image" src="https://github.com/user-attachments/assets/bf2fa084-2344-4bc7-b9e0-a29569cf9754" />

### Remediation

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

---

## 4.5 Secret Kullanımı

OpenShift workload:

```text
secret-env-app
```

Kasıtlı configuration:

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: database-credentials
      key: password
```

Buradaki eğitim mesajı:

```text
"Kubernetes Secret kullanılıyor"
            ≠
"Secret tamamen güvenlidir"
```

Secret environment variable olarak container process environment'ına aktarılır.

Container içerisinde örnek kontrol:

```bash
env | grep DB_
```

<img width="1845" height="928" alt="image" src="https://github.com/user-attachments/assets/7ab4f1ae-a4c7-4023-a1a0-11d624dbac4b" />

### Remediation

Uygulamanın desteklediği durumda secret'lar volume/file tabanlı tüketilebilir ve secret erişimi minimum service account yetkisi ile sınırlandırılmalıdır.

---

# 5. Overprivileged Service Account / RBAC

OpenShift workload:

```text
clusteradmin-app
```

ServiceAccount:

```text
clusteradmin-sa
```

Kasıtlı RBAC:

```text
clusteradmin-sa
     ↓
ClusterRoleBinding
     ↓
cluster-admin
```

Kontrol:

```bash
oc auth can-i '*' '*' \
  --as system:serviceaccount:demo-vulnerabilities:clusteradmin-sa
```

Beklenen:

```text
yes
```

Risk:

```text
Application vulnerability
        ↓
Container compromise
        ↓
ServiceAccount token
        ↓
cluster-admin permission
        ↓
Cluster-wide impact
```
> Not: Prisma Compute sürümüne ve etkin policy setine göre `cluster-admin ServiceAccount` doğrudan ayrı bir compliance finding olarak görünmeyebilir. Bu nedenle bu demo Prisma visibility + OpenShift RBAC doğrulaması birlikte kullanılarak anlatılabilir.

### Remediation

```text
cluster-admin
     ↓
Namespace-scoped Role
     +
RoleBinding
     ↓
Only required resources + verbs
```

---

