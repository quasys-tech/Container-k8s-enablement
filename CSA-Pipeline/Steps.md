# CSA Workshop – Building a Secure Container Pipeline

In this lab you take the **frontend** of a small online shop (**CSA Shop**) through a secure pipeline:

**IaC scan → build → image scan → fix → SBOM → push → sign → verify → deploy (admission control) → network policies**

| Tool | Used for |
|---|---|
| `checkov` | IaC / compliance scanning of Dockerfiles and Kubernetes YAML |
| `twistcli` | Vulnerability + compliance scanning of container images (Prisma Cloud) |
| `syft` | SBOM generation |
| `cosign` | Image signing and signature verification |
| `docker` / `oc` | Build, push, deploy |

<img width="1417" height="902" alt="image" src="https://github.com/user-attachments/assets/8d12eb94-3933-4646-a933-723b75f0bb43" />


---

## 0. Preparation

### 0.1 Set your variables

```bash
cd csa-shop
export ME=<your-name>                                           # e.g. student01
export NS=<your-openshift-namespace>                            # given by the instructor
export REGISTRY=csa-harbor.quasys.com.tr:40644/csa-pipeline
export IMAGE=$REGISTRY/csa-shop-frontend-$ME
```

### 0.2 Open Harbor (image registry)

Open the Harbor URL in your browser and log in with the credentials from the instructor. Then log in from the terminal:

```bash
docker login csa-harbor.quasys.com.tr:40644
```

<img width="662" height="937" alt="image" src="https://github.com/user-attachments/assets/99a2037d-5470-473c-b5ba-a8e161b335fd" />

<img width="1427" height="847" alt="image" src="https://github.com/user-attachments/assets/0a2a8ce9-7a55-4d27-b1d7-686bfd8f2314" />

Note: users can see each others projects but cant modify them. Select your users project - Only on that project your demo user will have a Developer role.

### 0.3 Open OpenShift

Log in to the OpenShift web console. :


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

ADD-CHECKOV-DOCKERFILE-NONCOMPLIANT-RESULT-IMAGE

❓ Open the file and match each finding to the line that causes it.

---

## Step 2 – Build the compliant but vulnerable image and scan it

`Dockerfile.vulnerable` fixes every Dockerfile finding: pinned tag, non-root user, `HEALTHCHECK`, `COPY`, and no secrets.

```bash
checkov -f frontend/Dockerfile.vulnerable --framework dockerfile,secrets --compact   # → 0 failed
docker build -t $IMAGE:vulnerable -f frontend/Dockerfile.vulnerable frontend
twistcli images scan --address $TWISTLOCK_ADDRESS -u $TWISTCLIUSER -p $TWISTCLIPASSWORD --details $IMAGE:vulnerable
```

**Expected:** compliance **0**, but **~165 vulnerabilities** (17 critical / 77 high). Threshold check: **FAIL**.

ADD-TWISTCLI-VULNERABLE-RESULT-IMAGE
ADD-PRISMA-CONSOLE-VULNERABLE-IMAGE-RESULT-IMAGE

💡 **Lesson:** a clean Dockerfile does not mean a clean image. The base image (`nginx:1.25` on old Debian packages) brings the CVEs.

---

## Step 3 – Build the secure image and scan it

`Dockerfile` uses a minimal **distroless** nginx base (no shell, no package manager), pinned by digest, running as non-root.

```bash
diff frontend/Dockerfile.vulnerable frontend/Dockerfile                    # what changed?
checkov -f frontend/Dockerfile --framework dockerfile,secrets --compact    # → 0 failed
docker build -t $IMAGE:v1 -f frontend/Dockerfile frontend
twistcli images scan --address $TWISTLOCK_ADDRESS -u $TWISTCLIUSER -p $TWISTCLIPASSWORD --details $IMAGE:v1
```

**Expected:** vulnerabilities **0**, compliance **0**, both threshold checks **PASS**.

ADD-TWISTCLI-SECURE-RESULT-IMAGE

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

ADD-SYFT-OUTPUT-IMAGE

---

## Step 5 – Push the image to Harbor

```bash
docker push $IMAGE:v1
export DIGEST_REF=$(docker inspect --format '{{index .RepoDigests 0}}' $IMAGE:v1)
echo $DIGEST_REF            # → ...csa-shop-frontend-<me>@sha256:....
```

From now on, always use the **digest** (`@sha256:...`), never the tag. A tag can be moved to point at a different image; a digest can't.

Check the image in Harbor: **Projects → csa-pipeline → csa-shop-frontend-\<me\>**.

ADD-HARBOR-PUSHED-IMAGE-IMAGE
ADD-HARBOR-IMAGE-DIGEST-IMAGE

---

## Step 6 – Sign the image with cosign and verify the signature

The instructor gives you `cosign.key`, `cosign.pub` and the key password.

```bash
export COSIGN_PASSWORD=<key-password>
cosign sign --key cosign.key --tlog-upload=false --new-bundle-format=false --use-signing-config=false -y $DIGEST_REF
```

Verify it:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true $DIGEST_REF
cosign tree $DIGEST_REF          # shows the attached .sig
```

**Expected:** `The cosign claims were validated` / `The signatures were verified against the specified public key`.

> `--tlog-upload=false` / `--insecure-ignore-tlog`: this lab signs offline, without the public Sigstore transparency log.

ADD-COSIGN-VERIFY-OUTPUT-IMAGE
ADD-HARBOR-SIGNED-IMAGE-IMAGE

---

# Part 2 – OpenShift deployment

## Step 7 – IaC scan the backend YAML and deploy the backend

The backend image is already built, scanned, pushed and signed by the instructor.

```bash
checkov -d openshift/backend --framework kubernetes,secrets --compact
```

**Expected:** **0 failed**, 7 skipped. Each skip is a documented exception (see the `checkov.io/skip*` annotations).

ADD-CHECKOV-BACKEND-YAML-RESULT-IMAGE

The DB password is **not** stored in git, so create it as a Secret, then deploy:

```bash
oc create secret generic backend-db --from-literal=DB_PASSWORD='<password-from-instructor>' -n $NS
oc apply -f openshift/backend/ -n $NS
oc rollout status deploy/backend -n $NS
```

ADD-OPENSHIFT-BACKEND-RUNNING-IMAGE

---

## Step 8 – IaC scan the frontend Deployment YAML

First the **insecure** variant:

```bash
checkov -f openshift/frontend-vulnerable/deployment-vulnerable.yaml --framework kubernetes --compact
```

**Expected:** **27 failed**: privileged, root, hostNetwork/hostPID/hostIPC, Docker socket, `SYS_ADMIN`, no limits, no probes, `latest` tag...

ADD-CHECKOV-FRONTEND-VULNERABLE-YAML-RESULT-IMAGE

Then the **secure** one:

```bash
checkov -d openshift/frontend --framework kubernetes --compact
```

**Expected:** only **2 failed**, both about the image (`CHANGEME`: no tag pinning, no digest). You fix those in the next steps.

❓ Compare `deployment-vulnerable.yaml` and `frontend/01-deployment.yaml` side by side.

---

## Step 9 – Try to deploy with a tag (admission control)

Put the **tag** into the Deployment and try to deploy:

```bash
sed -i "s#image: .*#image: \"$IMAGE:v1\"#" openshift/frontend/01-deployment.yaml
oc apply -f openshift/frontend/ -n $NS
oc get events -n $NS --sort-by=.lastTimestamp | tail
```

**Expected:** **rejected** by the Prisma Cloud admission controller, because only **digest-pinned, signed** images are allowed. Try `:latest` too.

ADD-ADMISSION-REJECTED-TAG-IMAGE
ADD-PRISMA-ADMISSION-AUDIT-IMAGE

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

ADD-OPENSHIFT-TOPOLOGY-VIEW-IMAGE
ADD-CSA-SHOP-WEB-UI-IMAGE

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

ADD-NETWORK-POLICY-DIAGRAM-IMAGE

Test again:

```bash
oc run np-test --rm -i --image=registry.access.redhat.com/ubi9/ubi-minimal --restart=Never -n $NS -- \
  curl -s -m 3 http://backend:8080/api/health          # → times out (blocked)
```

The shop in the browser **still works**: router → frontend → backend → DB is allowed.

ADD-NETWORK-POLICY-BLOCKED-TEST-IMAGE
ADD-CSA-SHOP-STILL-WORKING-IMAGE

---

## 🎉 Summary

| Stage | Control | Tool |
|---|---|---|
| Write | Dockerfile / YAML compliance | checkov |
| Build | Minimal, pinned, non-root base image | Dockerfile |
| Scan | CVEs + image compliance | twistcli |
| Inventory | SBOM | syft |
| Publish | Push by digest | Harbor |
| Trust | Sign + verify | cosign |
| Deploy | Only signed, digest-pinned images | Prisma Cloud admission |
| Run | Non-root, read-only FS, limits, least-privilege network | OpenShift SCC + NetworkPolicy |

ADD-FINAL-PIPELINE-OVERVIEW-IMAGE
