# Prisma Cloud Compute — Runtime Security Demo Rehberi

Bu demoda, kasıtlı olarak kötü niyetli davranış sergileyen container'ları `demo-vulnerabilities` namespace'inde çalıştırıyoruz ve Prisma Cloud Defender'ın bu davranışları runtime'da nasıl yakaladığını gösteriyoruz. Amaç; katılımcıların "çalışan bir container içindeki şüpheli aktivite Prisma'da nereden, nasıl görünür" sorusunu canlı görmesi.

> Not: Tüm davranışlar zararsız simülasyonlardır (gerçek mining / gerçek zarar yoktur), kontrollü bir eğitim ortamıdır.

---

## 1. Demodaki Container'lar

Policy: **`demo-vulnerabilities-strict`** (runtime container policy, `demo-vulnerabilities` namespace'ine bağlı).

| Pod / Deployment | Kullanılan Image | Simüle Edilen Davranış | Defender Tespiti | Etki (Effect) |
|---|---|---|---|---|
| `runtime-demo-crypto-miner` | `quay.io/umut_celik/runtime-demo-crypto-miner` | `xmrig` ile mining pool'a bağlanma | **Crypto miner** (processes) | 🔴 Prevent (bloklanır) |
| `runtime-demo-suid-escalation` | `quay.io/umut_celik/runtime-demo-suid-escalation` | `/bin/bash`'in setuid-root kopyasını oluşturma | **SUID binary** (processes) | 🔴 Prevent (bloklanır) |
| `runtime-demo-lateral-movement` | `quay.io/umut_celik/runtime-demo-lateral-movement` | Service account token ile Kubernetes API keşfi (recon) | **Lateral movement / K8s attack** (kubernetes) | 🔴 Prevent (bloklanır) |

**Neden uyarı veriyorlar?**
- **crypto-miner:** `xmrig` bilinen bir mining aracı ve bir mining pool'una bağlanmaya çalışıyor. Defender bunu kripto madencilik davranışı olarak tanıyıp çalıştırmayı **engelliyor** (prevent).
- **suid-escalation:** Container içinde root'a yetki yükseltmeye yarayan setuid'li bir binary oluşturuluyor. Bu klasik bir privilege escalation göstergesi; Defender binary'nin çalıştırılmasını **engelliyor** (prevent).
- **lateral-movement:** Pod, mount edilmiş SA token'ını okuyup Kubernetes API'ye (pods/secrets/namespaces) sorgu atıyor. Bu, ele geçirilmiş bir pod'un cluster içinde yayılma (lateral movement) davranışıdır; Defender **alert** üretiyor.

---

## 2. Container Image İçerikleri (Dockerfile + entrypoint)

Her container'ın Dockerfile'ı ve davranışı çalıştıran `entrypoint.sh` dosyası aşağıdadır.

### 2.1 crypto-miner

**Dockerfile**
```dockerfile
# Mevcut xmrig iceren imaji baz alir, sadece entrypoint'i degistirir
FROM quay.io/umut_celik/sandbox-test-crypto:latest
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**entrypoint.sh**
```sh
#!/bin/sh
# PRISMA RUNTIME DEMO - CRYPTO MINER
# Davranis: xmrig ile mining pool'a baglanma
# Tespit  : Crypto miner (prevent -> BLOKLANIR)
# NOT: --no-cpu ile calisir, GERCEK MINING YOK. Sadece tespit yemi.
set +e

POOL="${POOL:-pool.supportxmr.com:3333}"
INTERVAL="${INTERVAL:-45}"

echo "PRISMA RUNTIME DEMO - CRYPTO MINER (pool: ${POOL})"

while true; do
  echo "[$(date)] xmrig pool'a baglanmaya calisiyor (mining KAPALI)..."
  timeout 30 xmrig --no-cpu -o "${POOL}" -u demo -p x --donate-level=1 2>&1 | head -20
  RC=$?
  if [ "$RC" = "126" ] || [ "$RC" = "127" ]; then
    echo "[$(date)] >>> Defender xmrig calismasini ENGELLEDI (prevent calisti)"
  fi
  echo "[$(date)] ${INTERVAL} sn sonra tekrar"
  sleep "${INTERVAL}"
done
```

### 2.2 suid-escalation

**Dockerfile**
```dockerfile
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash netcat-openbsd curl ca-certificates procps iproute2 \
 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**entrypoint.sh**
```bash
#!/usr/bin/env bash
# PRISMA RUNTIME DEMO - SUID PRIVILEGE ESCALATION
# Davranis: bash'in suid-root kopyasini olusturup calistirma
# Tespit  : SUID binary (prevent -> BLOKLANIR)
set +e

INTERVAL="${INTERVAL:-45}"
SUID_BIN=/tmp/rootbash

echo "PRISMA RUNTIME DEMO - SUID ESCALATION"

while true; do
  echo "[$(date)] bash kopyalaniyor -> ${SUID_BIN}"
  cp /bin/bash "${SUID_BIN}" 2>/dev/null

  echo "[$(date)] setuid biti ekleniyor (chmod 4755)..."
  chmod 4755 "${SUID_BIN}" 2>&1
  ls -l "${SUID_BIN}" 2>/dev/null

  echo "[$(date)] suid binary calistiriliyor..."
  "${SUID_BIN}" -p -c 'id' 2>&1
  RC=$?
  if [ "$RC" = "126" ] || [ "$RC" = "127" ]; then
    echo "[$(date)] >>> Defender suid binary'yi ENGELLEDI (prevent calisti)"
  fi

  rm -f "${SUID_BIN}" 2>/dev/null
  echo "[$(date)] ${INTERVAL} sn sonra tekrar"
  sleep "${INTERVAL}"
done
```

### 2.3 lateral-movement

**Dockerfile**
```dockerfile
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash netcat-openbsd curl ca-certificates procps iproute2 \
 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

**entrypoint.sh**
```bash
#!/usr/bin/env bash
# PRISMA RUNTIME DEMO - LATERAL MOVEMENT / K8S RECON
# Davranis: port tarama + service account token ile K8s API kesfi (recon)
# Tespit  : Lateral movement / Kubernetes attack (alert)
# NOT: Tum istekler cluster'a read-only. Hicbir sey degistirilmez.
set +e

INTERVAL="${INTERVAL:-45}"
SA=/var/run/secrets/kubernetes.io/serviceaccount
APISERVER="https://kubernetes.default.svc"

echo "PRISMA RUNTIME DEMO - LATERAL MOVEMENT"

while true; do
  echo "[$(date)] --- Port taramasi (service network) ---"
  for ip in 172.30.0.1 10.131.0.1; do
    for port in 443 6443 2379 22 10250; do
      if timeout 1 bash -c "echo > /dev/tcp/${ip}/${port}" 2>/dev/null; then
        echo "  ACIK: ${ip}:${port}"
      fi
    done
  done

  echo "[$(date)] --- Service account token ile K8s API recon ---"
  TOKEN=$(cat ${SA}/token 2>/dev/null)
  NS=$(cat ${SA}/namespace 2>/dev/null)
  if [ -n "${TOKEN}" ]; then
    echo "  SA token okundu (ns=${NS}), API sorgulaniyor..."
    curl -sk --max-time 5 -H "Authorization: Bearer ${TOKEN}" \
      "${APISERVER}/api/v1/namespaces/${NS}/pods"    -o /dev/null -w "  pods    -> HTTP %{http_code}\n"
    curl -sk --max-time 5 -H "Authorization: Bearer ${TOKEN}" \
      "${APISERVER}/api/v1/namespaces/${NS}/secrets" -o /dev/null -w "  secrets -> HTTP %{http_code}\n"
    curl -sk --max-time 5 -H "Authorization: Bearer ${TOKEN}" \
      "${APISERVER}/api/v1/namespaces"               -o /dev/null -w "  all-ns  -> HTTP %{http_code}\n"
  else
    echo "  SA token bulunamadi"
  fi

  echo "[$(date)] ${INTERVAL} sn sonra tekrar"
  sleep "${INTERVAL}"
done
```

---

## 3. Runtime'ın İncelenmesi (Katılımcı Adımları)

### Adım 1 — Pod'ların çalıştığını gör
```bash
oc get pods -n demo-vulnerabilities -l demo=runtime-security
```
Üç pod da `Running` durumda olmalı.

<img width="2262" height="537" alt="image" src="https://github.com/user-attachments/assets/8a9850f2-99b4-4344-8482-59bd33378b72" />


### Adım 2 — Radar üzerinde genel görünüm
Menü: **Radars > Containers**. Üstten namespace filtresi: `demo-vulnerabilities`.
Burada container'lar risk durumuna göre renklenir — davranış sergileyenler **kırmızı/sarı** hexagon olarak öne çıkar.

<img width="1907" height="1040" alt="image" src="https://github.com/user-attachments/assets/8fd8ba26-16d5-4f81-b41b-1790da94dcff" />


### Adım 3 — Audit'leri (olayları) listele
Menü: **Monitor > Events > Container audits**. Namespace'e göre filtrele.
Her satır bir tespit: zaman, container, tespit tipi (processes / kubernetes), ve etki (**prevent** / **alert**).

<img width="2497" height="1132" alt="image" src="https://github.com/user-attachments/assets/8b95379a-9f03-4508-963d-345ed16fc784" />
<img width="2505" height="1217" alt="image" src="https://github.com/user-attachments/assets/e2af190b-7532-4caa-9ef5-3b4d7dbaac98" />



### Adım 4 — Bir olayın detayına in
Herhangi bir audit satırına tıkla. Açılan detayda şunları göster:
- **Hangi process/komut** tetikledi (ör. `xmrig`, `rootbash`, K8s API isteği),
- **Effect** (engellendi mi, sadece uyarı mı),
- Hangi **kurala** (`demo-vulnerabilities-strict`) takıldığı.

<img width="1472" height="876" alt="image" src="https://github.com/user-attachments/assets/133c4e95-92ee-4a78-88bc-9dc97c275cd8" />   
<img width="1496" height="962" alt="image" src="https://github.com/user-attachments/assets/7bdf6625-d2cd-4931-a959-c83a83649a61" />   
<img width="1487" height="966" alt="image" src="https://github.com/user-attachments/assets/1afe6a7b-9c7c-40f0-b01c-35b072778d1b" />



### Adım 5 — Container içeride ne yapıyordu? (kanıt)
Prisma'nın gördüğü davranışı container log'undan da teyit et:
```bash
oc logs -n demo-vulnerabilities -l app=runtime-demo-crypto-miner --tail=15
oc logs -n demo-vulnerabilities -l app=runtime-demo-suid-escalation --tail=15
oc logs -n demo-vulnerabilities -l app=runtime-demo-lateral-movement --tail=20
```
crypto ve suid log'larında, prevent devrede olduğu için **`Operation not permitted` / `ENGELLEDI`** satırlarını göreceksin — yani davranış sadece tespit edilmekle kalmadı, **engellendi**.

<img width="1185" height="507" alt="image" src="https://github.com/user-attachments/assets/291b5341-d912-4dc6-9af2-1a8760ed58a4" />   
<img width="1207" height="662" alt="image" src="https://github.com/user-attachments/assets/0048ef10-1bb3-4b64-8e4b-7b477a5ca90c" />


---

## 4. Özet Mesaj

- Prisma Defender, container **çalışırken** içindeki process ve davranışları izler.
- **Prevent** kuralları kötü niyetli işlemi anında **engeller** (crypto, suid); **alert** kuralları ise **uyarı** üretir (lateral movement).
- Her olay **Monitor > Events** altında, kaynağı ve etkisiyle birlikte izlenebilir.
- Aynı davranış container log'undan da doğrulanabilir — tespit ile gerçek aktivite birebir örtüşür.
