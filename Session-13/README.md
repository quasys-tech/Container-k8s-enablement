Kubernetes Iac Security
--------------------

Helmchart
--------------------
Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.

Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste.

https://helm.sh/

Iac Scanning with checkov
------------------------
Checkov scans cloud infrastructure configurations to find misconfigurations before they're deployed.

Checkov uses a common command line interface to manage and analyze infrastructure as code (IaC) scan results across platforms such as Terraform, CloudFormation, Kubernetes, Helm, ARM Templates and Serverless framework.

https://www.checkov.io/
https://github.com/bridgecrewio/checkov

Checkov
------------------------
```
checkov -d ./
checkov -d ./ --framework kubernetes
checkov -d ./ --framework kubernetes --skip-check CKV_K8S_15,CKV_K8S_28
```
![image](https://github.com/user-attachments/assets/0f5f7169-3baf-4b22-bcd3-0b7458d61035)
