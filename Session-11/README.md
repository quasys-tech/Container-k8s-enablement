Container Registry Security
----------------


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
