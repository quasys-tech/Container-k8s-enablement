
Admission Controller
----------------
https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/

Openshift RBAC
----------------
https://docs.openshift.com/container-platform/4.15/authentication/using-rbac.html

Openshift Self Managed Certificates
-----------------
https://docs.openshift.com/container-platform/4.15/security/index.html

Openshift LDAP Integration
-----------------
https://docs.openshift.com/container-platform/4.15/authentication/identity_providers/configuring-ldap-identity-provider.html

Replacing Ingress Certificate Openshift
-----------------
https://docs.openshift.com/container-platform/4.15/security/certificates/replacing-default-ingress-certificate.html

Disabling Self Provisioner Role on Openshift
-----------------
https://docs.openshift.com/container-platform/4.15/applications/projects/configuring-project-creation.html#disabling-project-self-provisioning_configuring-project-creation

Kubelet Certificates for Communicating Kubernetes Control Plane
-----------------
sh-5.1# ls /var/lib/kubelet/pki         
kubelet-client-2024-11-13-08-41-56.pem  kubelet-client-current.pem  kubelet-server-2024-11-13-08-41-59.pem  kubelet-server-current.pem

Kubeapiserver to Kubelet CA
-----------------
![image](https://github.com/user-attachments/assets/f05b8dcb-e835-46c3-a771-7d37e5298030)

Openshift Audit Logs
----------------
https://docs.openshift.com/container-platform/4.15/security/audit-log-view.html

Openshift File Integrity
------------------
- Install Openshift File Integrity Monitor

- Create fileintegrity custom resource with FileIntegrity.yml
  #Edit file on worker node.

      sh-4.2# echo "# integrity test" >> /host/etc/resolv.conf

- Check Status.
![image](https://github.com/user-attachments/assets/791f8a46-96be-4d57-b505-cc5e7d56d925)

- For details configmap:
![image](https://github.com/user-attachments/assets/11e8e778-4dc8-4833-9058-c7d5f1b2e5b0)



