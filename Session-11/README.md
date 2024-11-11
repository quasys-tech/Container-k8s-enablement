Container Registry Security
----------------


Image Signing and Verification
---------------
vagrant@container101-ubuntu:~/$ mkdir cosign-certs; cd cosign-certs
vagrant@container101-ubuntu:~/cosign-certs$cosign generate-key-pair
vagrant@container101-ubuntu:~/cosign-certs$cosign sign --key cosign.key quay.io/emre_celik/go-alpine:0.1-alpine3.18
vagrant@container101-ubuntu:~/cosign-certs$cosign verify --key cosign.pub quay.io/emre_celik/go-alpine:0.1-alpine3.18
