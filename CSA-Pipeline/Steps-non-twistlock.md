# CSA Workshop – Building a Secure Container Pipeline

In this lab you take the **frontend** of a small online shop (**CSA Shop**) through a secure pipeline:

**IaC scan → build → image scan → fix → SBOM → push → sign → verify → deploy (admission control) → network policies**

| Tool | Used for |
|---|---|
| `checkov` | IaC / compliance scanning of Dockerfiles and Kubernetes YAML |
| `trivy` | Vulnerability + misconfiguration scanning of container images |
| `syft` | SBOM generation |
| `cosign` | Image signing and signature verification |
| `docker` / `oc` | Build, push, deploy |

<img width="1417" height="902" alt="image" src="https://github.com/user-attachments/assets/8d12eb94-3933-4646-a933-723b75f0bb43" />


---

## 0. Preparation

### 0.1 Set your variables

If the bellow commands return empty ask your instrurctor to set  the enviorment variables
```bash
echo $ME
echo $NS
echo $REGISTRY
echo $IMAGE 
```

Seperate from bellow you need to set these env value yourself - ask the password of the cosign key from your register than run the command bellows
```bash
export COSIGN_PASSWORD=RETRIVE-FROM-INSTRUCTOR  # Change the password with the one your instructor provides
echo $COSIGN_PASSWORD
  // expectation is to see the password value
```


### 0.2 Open Harbor (image registry)

Open the Harbor URL in your browser and log in (no credentials at the cli level). Then log in from the terminal:

```bash
root@student-02:~/lab-files/secure-pipeline-lab# docker login csa-harbor.quasys.com.tr:40644
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

<img width="662" height="937" alt="image" src="https://github.com/user-attachments/assets/99a2037d-5470-473c-b5ba-a8e161b335fd" />

<img width="1427" height="847" alt="image" src="https://github.com/user-attachments/assets/0a2a8ce9-7a55-4d27-b1d7-686bfd8f2314" />

Note: users can see each others projects but cant modify them. Select your users project - Only on that project your demo user will have a Developer role.

### 0.3 Open OpenShift

Log in to the OpenShift web console. Console link will be provided by instructor.


For cli interactions your users already auto logged in at the OpenShift Cluster your instructor provided. Check the connection with oc whoami or oc get pods commands.

```bash
root@student-03:~/lab-files# oc get pods
No resources found in demo-project3 namespace.
root@student-03:~/lab-files# 
```

<img width="2260" height="1197" alt="image" src="https://github.com/user-attachments/assets/a9d77195-924e-4a45-9b7a-ab171cb14925" />   
<img width="815" height="700" alt="image" src="https://github.com/user-attachments/assets/a2dbd8e6-4fc9-4f70-b28b-abddada5269b" />   
<img width="1986" height="1118" alt="image" src="https://github.com/user-attachments/assets/e4bc8678-0aa3-4fc7-a8e8-5c5e73aa01ec" />




### 0.4 Project layout

```
backend /                   # step 0: has the backend Dockerfiles - not part of this lab but you can look at the files if you want
frontend/
  Dockerfile.noncompliant   # step 1: bad practices (IaC findings)
  Dockerfile.vulnerable     # step 2: compliant, but an old base image full of CVEs
  Dockerfile                # step 3: compliant and no CVEs
openshift/
  backend/                  # backend Kubernetes YAML
  frontend/                 # secure and vulnerable frontend Kubernetes YAML (image = CHANGEME)
  networkpolicies/          # network policies for your namespace
```

---

# Part 1 – Container image pipeline

## Step 1 – IaC scan the non-compliant Dockerfile

Scan the Dockerfile **before** building anything.

```bash
checkov -f frontend/Dockerfile.noncompliant --framework dockerfile,secrets --compact
```

**Expected:** ~13 failed checks, including root user, `latest` tag, port 22, `ADD` instead of `COPY`, `sudo`, `chpasswd`, no `HEALTHCHECK`, and **hard-coded AWS keys**.

<img width="1803" height="502" alt="image" src="https://github.com/user-attachments/assets/2ecf54e1-d8f6-4c74-85b6-0d0e212d57de" />


❓ Open the file and match each finding to the line that causes it. 

---

## Step 2 – Build the compliant but vulnerable image and scan it

`Dockerfile.vulnerable` fixes every Dockerfile finding: pinned tag, non-root user, `HEALTHCHECK`, `COPY`, and no secrets.

```bash
checkov -f frontend/Dockerfile.vulnerable --framework dockerfile,secrets --compact   # → 0 failed
docker build -t $IMAGE:vulnerable -f frontend/Dockerfile.vulnerable frontend
docker images
  REPOSITORY                                                    TAG          IMAGE ID       CREATED          SIZE
  csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend   vulnerable   f15ea869ec3d   11 seconds ago   188M
```

Scan the image with trivy (the first run downloads the vulnerability DB, it can take a minute):

```bash
# 1) Full report: OS + library vulnerabilities
trivy image --scanners vuln $IMAGE:vulnerable

# 2) Image config check (root user, secrets in layers, etc.) - the "compliance" part
trivy image --scanners misconfig,secret --image-config-scanners misconfig,secret $IMAGE:vulnerable

# 3) Threshold check (pipeline gate): fail if there is any CRITICAL vulnerability
trivy image --scanners vuln --severity CRITICAL --exit-code 1 --quiet $IMAGE:vulnerable
echo "Threshold check exit code: $?"      # 1 = FAIL, 0 = PASS
```

**Expected:** image config findings **0**, but **a lot of vulnerabilities** (many CRITICAL / HIGH). Threshold check exit code **1** → **FAIL**.

checkov IaC scan will return celan - but the packages at the Container Images might have vulknerabilities, to detect them we're scanning the container image with trivy.

ADD-TRIVY-VULNERABLE-SCAN-IMAGE

Output of trivy (summary line - your numbers can be different, the trivy DB is updated daily)
```bash
csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend:vulnerable (debian 12.x)
=====================================================================================
Total: XXX (UNKNOWN: X, LOW: XX, MEDIUM: XX, HIGH: XX, CRITICAL: XX)

Threshold check exit code: 1
```


💡 **Lesson:** a clean Dockerfile does not mean a clean image. The base image (`nginx:1.25` on old Debian packages) brings the CVEs.

---

## Step 3 – Build the secure image and scan it

`Dockerfile` uses a minimal **distroless** nginx base (no shell, no package manager), pinned by digest, running as non-root.

```bash
diff frontend/Dockerfile.vulnerable frontend/Dockerfile                    # what changed?
checkov -f frontend/Dockerfile --framework dockerfile,secrets --compact    # → 0 failed
docker build -t $IMAGE:v1 -f frontend/Dockerfile frontend

trivy image --scanners vuln $IMAGE:v1
trivy image --scanners misconfig,secret --image-config-scanners misconfig,secret $IMAGE:v1
trivy image --scanners vuln --severity CRITICAL --exit-code 1 --quiet $IMAGE:v1
echo "Threshold check exit code: $?"      # 1 = FAIL, 0 = PASS
```

**Expected:** **0 CRITICAL / 0 HIGH** vulnerabilities, image config findings **0**, threshold check exit code **0** → **PASS**.

Output:    
```bash
csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend:v1 (debian 12.x)
=============================================================================
Total: 0 (UNKNOWN: 0, LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0)

Threshold check exit code: 0
```

> Trivy can sometimes list a few LOW / unfixed findings even on distroless images. Add `--ignore-unfixed` to hide vulnerabilities that have no fix yet.

```bash
docker images | grep csa-shop-frontend-$ME      # compare sizes: ~130 MB vs ~19 MB
```

---

## Step 4 – Generate an SBOM

An SBOM (Software Bill of Materials) lists every package inside the image.

```bash
syft $IMAGE:v1                                          # quick table view
syft $IMAGE:v1 -o cyclonedx-json > sbom-frontend.cdx.json
syft $IMAGE:vulnerable | wc -l ; syft $IMAGE:v1 | wc -l # compare package counts
```

```bash
root@student-02:~/lab-files/secure-pipeline-lab# syft $IMAGE:vulnerable | wc -l ; syft $IMAGE:v1 | wc -l
 ✔ Loaded image                                                                                      csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend:vulnerable
 ✔ Parsed image                                                                                     sha256:f15ea869ec3dcb6ca04332d11ec2223f861723faf22e7e2801f226e8a25857b7
 ✔ Cataloged contents                                                                                      ad0a1aac9ea3772c4c9fe11caf83c9dd462e0bcd6b75bcc6d4b925bace50dc10
   ├── ✔ Packages                        [150 packages]  
   ├── ✔ Executables                     [843 executables]  
   ├── ✔ File metadata                   [3,712 locations]  
A newer version of syft is available for download: 1.54.0 (installed version is 1.52.0)
151
 ✔ Loaded image                                                                                              csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend:v1
 ✔ Parsed image                                                                                     sha256:86689a08965524b0886c79d2796197f6f7f5ff4030400d0f5139218a452cb8e6
 ✔ Cataloged contents                                                                                      49499e9de9a7c5751382d5129cb84267f7a94845e4689d436b9d23091e8bcf20
   ├── ✔ Packages                        [25 packages]  
   ├── ✔ Executables                     [32 executables]  
   ├── ✔ File metadata                   [110 locations]  
A newer version of syft is available for download: 1.54.0 (installed version is 1.52.0)
26
```

---

## Step 5 – Push the image to Harbor

```bash
docker push $IMAGE:v1
export DIGEST_REF=$(docker inspect --format '{{index .RepoDigests 0}}' $IMAGE:v1)
echo $DIGEST_REF            # → ...csa-shop-frontend-<me>@sha256:....
```

From now on, always use the **digest** (`@sha256:...`), never the tag. A tag can be moved to point at a different image; a digest can't.

Check the image in Harbor: **Projects → csa-pipeline → csa-shop-frontend-\<me\>**.

<img width="2517" height="637" alt="image" src="https://github.com/user-attachments/assets/46f7bea5-4729-4f56-9363-d207a7f13c6d" />

Your digest values can be different from values bellow!

```bash
root@student-02:~/lab-files/secure-pipeline-lab# echo $DIGEST_REF
csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend@sha256:05d3a7227cb7026ddbd0aefe2c94730e332e42ed7176ca9e0ce7ef06a4da9cc3
root@student-02:~/lab-files/secure-pipeline-lab# 
```

---

## Step 6 – Sign the image with cosign and verify the signature

The instructor gives you `cosign.key`, `cosign.pub` and the key password.

```bash

cosign sign --key cosign.key --tlog-upload=false --new-bundle-format=false --use-signing-config=false -y $DIGEST_REF
```

Verify it:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true $DIGEST_REF
cosign tree $DIGEST_REF          # shows the attached .sig
```

**Expected:** `The cosign claims were validated` / `The signatures were verified against the specified public key`.

> `--tlog-upload=false` / `--insecure-ignore-tlog`: this lab signs offline, without the public Sigstore transparency log.

```bash
root@student-02:~/lab-files/secure-pipeline-lab# cosign verify --key cosign.pub --insecure-ignore-tlog=true $DIGEST_REF
WARNING: Skipping tlog verification is an insecure practice that lacks transparency and auditability verification for the signature.

Verification for csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend@sha256:05d3a7227cb7026ddbd0aefe2c94730e332e42ed7176ca9e0ce7ef06a4da9cc3 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend"},"image":{"docker-manifest-digest":"sha256:05d3a7227cb7026ddbd0aefe2c94730e332e42ed7176ca9e0ce7ef06a4da9cc3"},"type":"cosign container image signature"},"optional":null}]
root@student-02:~/lab-files/secure-pipeline-lab# cosign tree $DIGEST_REF
📦 Supply Chain Security Related artifacts for an image: csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend@sha256:05d3a7227cb7026ddbd0aefe2c94730e332e42ed7176ca9e0ce7ef06a4da9cc3
└── 🔐 Signatures for an image tag: csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend:sha256-05d3a7227cb7026ddbd0aefe2c94730e332e42ed7176ca9e0ce7ef06a4da9cc3.sig
   └── 🍒 sha256:0f43dafb1d1713ac15c600bfb97612be48a6444fc6bb260e8d7d48b1b6c6f231
└── 🔗 application/vnd.oci.image.config.v1+json artifacts via OCI referrer: csa-harbor.quasys.com.tr:40644/demo-user2/csa-shop-frontend@sha256:38bf1f344e57df2ff994ea11af58b2d8a9a5f33e67ce42e7ff1a383a71ee39a0
   └── 🍒 sha256:0f43dafb1d1713ac15c600bfb97612be48a6444fc6bb260e8d7d48b1b6c6f231
```
---

# Part 2 – OpenShift deployment

## Step 7 – IaC scan the backend YAML and deploy the backend

The backend image is already built, scanned, pushed and signed by the instructor.

```bash
checkov -d openshift/backend --framework kubernetes,secrets --compact
```

**Expected:** **0 failed**, 7 skipped. Each skip is a documented exception (see the `checkov.io/skip*` annotations).

```bash
kubernetes scan results:

Passed checks: 86, Failed checks: 0, Skipped checks: 7
```

The DB password is **not** stored in git, so create it as a Secret, then deploy:
The DB_PASSWORD env values at your terminal already has the value so use that

```bash
oc create secret generic backend-db --from-literal=DB_PASSWORD=$DB_PASSWORD -n $NS
oc apply -f openshift/backend/ -n $NS
oc rollout status deploy/backend -n $NS
```

<img width="1917" height="748" alt="image" src="https://github.com/user-attachments/assets/94af05f2-e020-4ce9-8ab0-089851d30441" />


---

## Step 8 – IaC scan the frontend Deployment YAML

First the **insecure** variant:

```bash
checkov -f openshift/frontend-vulnerable/deployment-vulnerable.yaml --framework kubernetes --compact
```

**Expected:** **27 failed**: privileged, root, hostNetwork/hostPID/hostIPC, Docker socket, `SYS_ADMIN`, no limits, no probes, `latest` tag...

```bash
       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By Prisma Cloud | version: 3.3.22 
Update available 3.3.22 -> 3.3.23
Run pip3 install -U checkov to update 


kubernetes scan results:

Passed checks: 62, Failed checks: 27, Skipped checks: 0

```

Then the **secure** one:

```bash
checkov -d openshift/frontend --framework kubernetes --compact
```

**Expected:** only **2 failed**, both about the image (`CHANGEME`: no tag pinning, no digest). You fix those in the next steps.

❓ Compare `deployment-vulnerable.yaml` and `frontend/01-deployment.yaml` side by side.

Output of 01-deployment scan:   
```bash
kubernetes scan results:

Passed checks: 85, Failed checks: 2, Skipped checks: 5
```

---

## Step 9 – Try to deploy with a tag (admission control)

Put the **tag** into the Deployment and try to deploy:

```bash
sed -i "s#image: .*#image: \"$IMAGE:v1\"#" openshift/frontend/01-deployment.yaml
oc apply -f openshift/frontend/ -n $NS
oc get events -n $NS --sort-by=.lastTimestamp | tail
```

**Expected:** **rejected** by the Prisma Cloud admission controller, because only **digest-pinned, signed** images are allowed. Try `:latest` too.


---

## Step 10 – Deploy with the signed digest

```bash
sed -i "s#image: .*#image: \"$DIGEST_REF\"#" openshift/frontend/01-deployment.yaml
checkov -d openshift/frontend --framework kubernetes --compact      # → 0 failed now
oc apply -f openshift/frontend/ -n $NS
oc rollout status deploy/frontend -n $NS
oc get route frontend -n $NS -o jsonpath='https://{.spec.host}{"\n"}'
```

Open the URL. The shop loads, the header shows **"API + DB online"**, and each product shows its stock. Place an order and watch the stock drop. That proves frontend → backend → database works.

<img width="1417" height="902" alt="image" src="https://github.com/user-attachments/assets/8d12eb94-3933-4646-a933-723b75f0bb43" />

<img width="2542" height="988" alt="image" src="https://github.com/user-attachments/assets/4ae173bb-428e-412a-9660-9e4377354155" />


> The Route is HTTPS only (edge TLS). `http://` is refused.

---

## Step 11 – Lock down traffic with network policies

Right now, **any** pod in the cluster can reach your frontend and backend. First prove it:

```bash
oc run np-test --rm -i --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -n $NS -- \
  curl -s -m 3 http://backend:8080/api/health          # → {"status":"ok"}  (open!)
```

Apply the policies:

```bash
oc apply -f openshift/networkpolicies/ -n $NS
oc get networkpolicy -n $NS
```

| Policy | Allows |
|---|---|
| `default-deny-all` | nothing (everything else is blocked) |
| `frontend-ingress-from-router` | OpenShift router → frontend :8080 |
| `frontend-egress-to-backend` + `backend-ingress-from-frontend` | frontend → backend :8080 |
| `backend-egress-to-postgresql` | backend → PostgreSQL in `csa-app-db` :5432 |
| `allow-dns-egress` | frontend + backend → CoreDNS in `openshift-dns` |

<img width="1417" height="902" alt="image" src="https://github.com/user-attachments/assets/8d12eb94-3933-4646-a933-723b75f0bb43" />

Test again:

```bash
oc run np-test --rm -i --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -n $NS -- \
  curl -s -m 3 http://backend:8080/api/health          # → times out (blocked)
```

The shop in the browser **still works**: router → frontend → backend → DB is allowed.


---

## 🎉 Summary

| Stage | Control | Tool |
|---|---|---|
| Write | Dockerfile / YAML compliance | checkov |
| Build | Minimal, pinned, non-root base image | Dockerfile |
| Scan | CVEs + image misconfiguration | trivy |
| Inventory | SBOM | syft |
| Publish | Push by digest | Harbor |
| Trust | Sign + verify | cosign |
| Deploy | Only signed, digest-pinned images | Prisma Cloud admission |
| Run | Non-root, read-only FS, limits, least-privilege network | OpenShift SCC + NetworkPolicy |
