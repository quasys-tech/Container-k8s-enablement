Container Registry Security
----------------

Build Application
--------------
    [vagrant@ocp-svc go-alpine]$ cd Docker-Build/go-alpine
    [vagrant@ocp-svc go-alpine]$ podman build -t go-alpine:0.1-alpine3.18 .

Scan Image on Local with twistcli
--------------
    [vagrant@ocp-svc go-alpine]$ twistcli images scan --user=$TW_USER --password=$TW_PASS --address=$TW_CONSOLE localhost/go-alpine:0.1-alpine3.18
    
    Scan results for: image localhost/go-alpine:0.1-alpine3.18 044d25ded588b2a2d52beda44bb6a64e986d10d19b4803864406b69de2eef911
    
    Vulnerabilities found for image localhost/go-alpine:0.1-alpine3.18: total - 16, critical - 1, high - 1, medium - 8, low - 6
    Vulnerability threshold check results: FAIL
    Scan failed due to vulnerability policy violations: Default - alert all components, 1 vulnerabilities. Blocking vulnerabilities by severity OR by risk factors. Severity distribution : [critical:1]
    
    Compliance found for image localhost/go-alpine:0.1-alpine3.18: total - 2, critical - 0, high - 2, medium - 0, low - 0
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
