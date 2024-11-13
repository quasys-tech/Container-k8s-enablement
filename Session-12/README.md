- ETCD encryption enable and check data.
- Kubectl hash control.
- Secret Scanning, Iac scanning.
- Compliance maddeleri.
- Self Provisioner örneği/ rbac kaldırma vs.
- Cyberark Conjur Example?
- Admission Control Analizi?
- Bileşenler arası sertifikalar, kubelet, api, etcd vs.
#https://docs.openshift.com/container-platform/4.15/security/index.html
- RBAC örneği, view only, edit role, rolebinding örneği.
- LDAP entegrasyonu örneği.
- Audit logs.
#https://docs.openshift.com/container-platform/4.15/security/audit-log-view.html
- File Integrity Monitor
#https://docs.openshift.com/container-platform/4.15/security/file_integrity_operator/file-integrity-operator-understanding.html#understanding-file-integrity-operator



Kubelet Certificates for Communicating Kubernetes Control Plane
-----------------
sh-5.1# ls /var/lib/kubelet/pki         
kubelet-client-2024-11-13-08-41-56.pem  kubelet-client-current.pem  kubelet-server-2024-11-13-08-41-59.pem  kubelet-server-current.pem

Kubeapiserver to Kubelet CA
-----------------
![image](https://github.com/user-attachments/assets/f05b8dcb-e835-46c3-a771-7d37e5298030)
