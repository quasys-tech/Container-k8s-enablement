Container Registry Security
----------------

Build Application
--------------
    [vagrant@ocp-svc go-alpine]$ cd Docker-Build/go-alpine
    [vagrant@ocp-svc go-alpine]$ podman build -t go-alpine:0.1-alpine3.18 .

Scan Image on Local with twistcli
--------------
    [vagrant@ocp-svc go-alpine]$ twistcli images scan --user=$TW_USER --password=$TW_PASS --address=$TW_CONSOLE localhost/go-alpine:0.1-alpine3.18

    Scan results for: image localhost/go-alpine:0.1-alpine3.18 7b1939f846e5b9a047ee086672d68e0f7288d5214db3317b19d9c71b788f07ad
    
    Vulnerabilities found for image localhost/go-alpine:0.1-alpine3.18: total - 16, critical - 1, high - 0, medium - 9, low - 6
    Vulnerability threshold check results: FAIL
    Scan failed due to vulnerability policy violations: Default - alert all components, 1 vulnerabilities. Blocking vulnerabilities by severity OR by risk factors. Severity distribution : [critical:1]
    
    Compliance found for image localhost/go-alpine:0.1-alpine3.18: total - 2, critical - 0, high - 2, medium - 0, low - 0
    Compliance threshold check results: FAIL
    Scan failed due to compliance policy violations: Default - alert on critical and high, 1 violations
    Link to the results in Console:

Build Application with New Dockerfile for Vulnerabilities
--------------
    [vagrant@ocp-svc go-alpine]$ cd Docker-Build/go-alpine-netip-fixed
    [vagrant@ocp-svc go-alpine]$ podman build -t go-alpine-netip-fixed:0.1-alpine3.18 .
    [vagrant@ocp-svc go-alpine]$ twistcli images scan --user=$TW_USER --password=$TW_PASS --address=$TW_CONSOLE localhost/go-alpine-netip-fixed:0.1-alpine3.18
    Scan results for: image localhost/go-alpine-netip-fixed:0.1-alpine3.18 66c7f7233b3b44039b36bc38798d88383d88bf5d39cf106583d6b3dc369bdf00
    
    Vulnerabilities found for image localhost/go-alpine-netip-fixed:0.1-alpine3.18: total - 4, critical - 0, high - 0, medium - 3, low - 1
    Vulnerability threshold check results: PASS
    
    Compliance found for image localhost/go-alpine-netip-fixed:0.1-alpine3.18: total - 2, critical - 0, high - 2, medium - 0, low - 0
    Compliance threshold check results: FAIL
    Scan failed due to compliance policy violations: Default - alert on critical and high, 2 violations
    


Build Application with New Dockerfile for Compliance
--------------
    [vagrant@ocp-svc go-alpine]$ cd Docker-Build/go-alpine-compliance-fixed
    [vagrant@ocp-svc go-alpine]$ podman build -t go-alpine-compliance-fixed:0.1-alpine3.18 .
    [vagrant@ocp-svc go-alpine-compliance-fixed]$ twistcli images scan --user=$TW_USER --password=$TW_PASS --address=$TW_CONSOLE localhost/go-alpine-compliance-fixed:0.1-alpine3.18
    
    Scan results for: image localhost/go-alpine-compliance-fixed:0.1-alpine3.18 6798d47eff3be93b026d97ee6b3e380ec24fe8072b319c3e6c5127138dc3461f
    
    Vulnerabilities found for image localhost/go-alpine-compliance-fixed:0.1-alpine3.18: total - 4, critical - 0, high - 0, medium - 3, low - 1
    Vulnerability threshold check results: PASS
    
    Compliance found for image localhost/go-alpine-compliance-fixed:0.1-alpine3.18: total - 1, critical - 0, high - 1, medium - 0, low - 0
    Compliance threshold check results: PASS


Prisma Cloud Trusted Images
---------------
![image](https://github.com/user-attachments/assets/f99f8a09-9408-44ca-b998-f28bd11bfaca)

CI Images Vulnerability
---------------
![image](https://github.com/user-attachments/assets/51b567a9-0b0c-4aae-93d2-868b5e481713)

CI Images Compliance
---------------
![image](https://github.com/user-attachments/assets/1e5569c0-d164-47f7-9bc9-6e4b64eafbb9)

Image Signing and Verification
---------------
    #Download cosign for image signing.
    vagrant@container101-ubuntu:~/$ wget https://github.com/sigstore/cosign/releases/download/v2.4.1/cosign-linux-amd64
    vagrant@container101-ubuntu:~/$ chmod +x cosign-linux-amd64
    vagrant@container101-ubuntu:~/$ mv cosign-linux-amd64 /usr/local/bin/cosign
    vagrant@container101-ubuntu:~/$ cosign version
    
    #Create directory and certificate pair
    vagrant@container101-ubuntu:~/$ mkdir cosign-certs; cd cosign-certs
    vagrant@container101-ubuntu:~/cosign-certs$cosign generate-key-pair
    vagrant@container101-ubuntu:~/cosign-certs$cosign sign --key cosign.key quay.io/emre_celik/go-alpine:0.1-alpine3.18
    vagrant@container101-ubuntu:~/cosign-certs$cosign verify --key cosign.pub quay.io/emre_celik/go-alpine:0.1-alpine3.18
    Verification for quay.io/emre_celik/go-alpine:0.1-alpine3.18 --
    The following checks were performed on each of these signatures:
      - The cosign claims were validated
      - Existence of the claims in the transparency log was verified offline
      - The signatures were verified against the specified public key

