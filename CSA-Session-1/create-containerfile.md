Bu örnekte 3 adet container image oluşturup twistcli tool'u ile taramasını gerçekleştireceğiz.

# Vulnerable Image

Bu image'ı oluşturmak için kullanacağımız paketlerde critical zafiyetler mevcut. Container image'ını oluşturabilmek için lab ortamında csa-session-1 dizinine girmeliyiz

```bash
root@student-01:~/lab-files# ls
Session-1   Session-11  Session-13  Session-15  Session-3  Session-5  Session-7  Session-9
Session-10  Session-12  Session-14  Session-2   Session-4  Session-6  Session-8  csa-session-1
root@student-01:~/lab-files# cd csa-session-1/
root@student-01:~/lab-files/csa-session-1# ls
Dockerfile.multistage  Dockerfile.secret  Dockerfile.vulnerable  requirements.txt
root@student-01:~/lab-files/csa-session-1# 
```

Sonrasında cat tool'u ile image'ı inceleyebiliriz

```bash
$ cat Dockerfile.vulnerable
FROM ...
```

Sonrasında image'ı build etmeliyiz
```bash
$ docker build   -f Dockerfile.vulnerable   -t container-sec-demo:vulnerable .

$ docker images
```

Build olduktan sonra taraması için aşağıdaki komutu çalıştırıyoruz. Twistcli console adresi eğitimlerdee değişiklik gösterebilir ! USERNAME ve PASSWORD env değerleri setlenmiş olduğuından sadece console kontrolü yapılmalıdır.
```bash
$ twistcli images scan \
  --address  https://console-twistlock.apps.ocp-qua-prod.quasys.com.tr \
  -u  $USERNAME \
  -p  $PASSWORD \
  --details \
  container-sec-demo:vulnerable
```
Output:

```bash
Scan results for: image container-sec-demo:vulnerable sha256:e5114a3c3439d583c907defdaf6158131bbacc5839d0ca6982524f691def17ce
Vulnerabilities
+----------------+----------+-------+-------------------------------------+---------+--------------------------------+------------+------------+-----------------------------------------------------------------------+
|      CVE       | SEVERITY | CVSS  |               PACKAGE               | VERSION |             STATUS             | PUBLISHED  | DISCOVERED |                              DESCRIPTION                              |
+----------------+----------+-------+-------------------------------------+---------+--------------------------------+------------+------------+-----------------------------------------------------------------------+
| CVE-2021-44228 | critical | 10.00 | org.apache.logging.log4j_log4j-core | 2.14.1  | fixed in 2.15.0, 2.12.2        | > 4 years  | < 1 hour   | Apache Log4j2 2.0-beta9 through 2.15.0 (excluding                     |
|                |          |       |                                     |         | > 4 years ago                  |            |            | security releases 2.12.2, 2.12.3, and 2.3.1) JNDI                     |
|                |          |       |                                     |         |                                |            |            | features used in configuration, log messages, and                     |
|                |          |       |                                     |         |                                |            |            | ...                                                                   |
+----------------+--
...
```

Buraki hata 
Base image temiz olsa bile uygulamanın içine koyduğumuz library zafiyetli olabilir. bu da attack surface'ı arttırabilir.

# Secret Image

Bu örnekte credentials'ların container image içerisinde env olarak gömüldüğü ccontainer image örneğini işleyeceğiz.
csa-session-1 dizinine olduğumuza emin olalım.

```bash
root@student-01:~/lab-files/csa-session-1# ls
Dockerfile.multistage  Dockerfile.secret  Dockerfile.vulnerable  requirements.txt
root@student-01:~/lab-files/csa-session-1# 
```

Sonrasında cat tool'u ile image'ı inceleyebiliriz.Hassas veri içeren ENV değerlerinin direk container image'a eklendiğini tespit edin.

```bash
$ cat Dockerfile.secret
FROM ...
```

Sonrasında image'ı build etmeliyiz
```bash
$ docker build   -f Dockerfile.secret   -t container-sec-demo:secret .

$ docker images
```

Build olduktan sonra taraması için aşağıdaki komutu çalıştırıyoruz.  Çıktıda ENV uyarılını inceleyin.
```bash
$ twistcli images scan \
  --address  https://console-twistlock.apps.ocp-qua-prod.quasys.com.tr \
  -u  $USERNAME \
  -p  $PASSWORD \
  --details \
  container-sec-demo:secret
```
Output:
```bash
Compliance Issues
+----------+------------------------------------------------------------------------+
| SEVERITY |                              DESCRIPTION                               |
+----------+------------------------------------------------------------------------+
| high     | (CIS_Docker_v1.5.0 - 4.1) Image should be created with a non-root user |
+----------+------------------------------------------------------------------------+
| high     | Sensitive information provided in environment variables                |
+----------+------------------------------------------------------------------------+
```

Buradaki hatalar
* Birincisi secret'ları image içine gömüyorsun:
```bash
ENV DB_USERNAME=admin
ENV DB_PASSWORD=SuperSecretPassword123
ENV API_KEY=abc123-super-secret-api-key
```
* İkinci hata, root user:
```bash
USER ...
```
Yukaridaki USER kısmı yok. Dolayısıyla uygulama default olarak root çalışır.
* Üçüncü problem de runtime image içinde pip gibi gereksiz araçların kalması.
```bash
Dockerfile.secret

❌ Hard-coded secrets
❌ Runs as root
❌ pip remains in runtime image
❌ Larger attack surface
```

# Multistage Safe Image

Bu örnekte multistage ile düşük profilli, Containerfile compliance kurallarina uyan uygun bir image build edeceğiz.

csa-session-1 dizinine olduğumuza emin olalım.

```bash
root@student-01:~/lab-files/csa-session-1# ls
Dockerfile.multistage  Dockerfile.secret  Dockerfile.vulnerable  requirements.txt
root@student-01:~/lab-files/csa-session-1# 
```

Sonrasında cat tool'u ile image'ı inceleyebiliriz.Hassas veri içeren ENV değerlerinin direk container image'a eklendiğini tespit edin.

```bash
$ cat Dockerfile.multistage
FROM ...
```

Sonrasında image'ı build etmeliyiz
```bash
$ docker build   -f Dockerfile.multistage   -t container-sec-demo:multistage .

$ docker images
```

Build olduktan sonra taraması için aşağıdaki komutu çalıştırıyoruz.  Çıktıda ENV uyarılını inceleyin.
```bash
$ twistcli images scan \
  --address  https://console-twistlock.apps.ocp-qua-prod.quasys.com.tr \
  -u  $USERNAME \
  -p  $PASSWORD \
  --details \
  container-sec-demo:multistage
```
Output:
```bash
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
|      CVE       | SEVERITY | CVSS | PACKAGE | VERSION  |     STATUS     | PUBLISHED  | DISCOVERED |                    DESCRIPTION                     |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
| CVE-2026-15534 | medium   | 5.70 | perl    | 5.40.1-6 | open           | 38 days    | < 1 hour   | Perl versions through 5.45.1 have out-of-bounds    |
|                |          |      |         |          |                |            |            | heap reads and writes during regular expression    |
|                |          |      |         |          |                |            |            | matching via an undersized superlinear cache in    |
|                |          |      |         |          |                |            |            | S_regm...                                          |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
| CVE-2026-27205 | medium   | 4.30 | flask   | 3.0.3    | fixed in 3.1.3 | > 6 months | < 1 hour   | Flask is a web server gateway interface (WSGI)     |
|                |          |      |         |          | > 6 months ago |            |            | web application framework. In versions 3.1.2 and   |
|                |          |      |         |          |                |            |            | below, when the session object is accessed, Flask  |
|                |          |      |         |          |                |            |            | shou...                                            |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
```

Multistage neleri doğru yapıyor?
* İlk avantajı multi-stage:
```bash
FROM python:3.12-slim AS builder
...
FROM python:3.12-slim
```
* Sadece gereken dependency'ler alınıyor:
```bash
COPY --from=builder /install /usr/local
```
* non-root
```bash
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -m appuser
USER 1001
```

* secret yok:
```bash
DB_PASSWORD
API_KEY
TOKEN
```
