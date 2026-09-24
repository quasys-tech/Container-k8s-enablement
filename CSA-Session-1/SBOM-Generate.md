In this example, users will create a multi-stage container from a Dockerfile and then scan it with **twistcli** to ensure it does not have any critical or high vulnerabilities. After that, users will use the **syft** tool to generate Software Bill of Materials (SBOM) files from that container image.

### 1. Access the Lab

Access the lab using the provided URL, username, and password shared in your session. Then, pick an available lab session.

### 2. Access the `csa-session2` Directory

Use the `cd` command to navigate to the target directory:

```bash
root@student-02:~/lab-files# ls
CSA-Session-1  Session-10  Session-12  Session-14  Session-2  Session-4  Session-6  Session-8  csa-session-1
Session-1      Session-11  Session-13  Session-15  Session-3  Session-5  Session-7  Session-9  csa-session2

root@student-02:~/lab-files# cd csa-session2  
root@student-02:~/lab-files/csa-session2# pwd
/root/lab-files/csa-session2
```

### 3. Examine the Files

There are three files in this directory: a **Dockerfile** used to build the image, an **app.py** application file, and a **requirements.txt** file required by the `pip install` command.

```bash
root@student-02:~/lab-files/csa-session2# ls
Dockerfile.multistage  app.py  requirements.txt
```

### 4. Generate the Container Image

Build the container image using the `docker build` command:

```bash
$ docker build -f Dockerfile.multistage -t container-sec-demo:multistage .

$ docker images
```

### 5. Scan the Image with `twistcli`

Use the command below to scan the container image for vulnerabilities and compliance issues:

```bash
$ twistcli images scan \
  --address https://console-twistlock.apps.ocp-qua-prod.quasys.com.tr \
  -u $USERNAME \
  -p $PASSWORD \
  --details \
  container-sec-demo:multistage
```

**Output:**
```bash
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
|      CVE       | SEVERITY | CVSS | PACKAGE | VERSION  |     STATUS     | PUBLISHED  | DISCOVERED |                    DESCRIPTION                     |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
| CVE-2026-15534 | medium   | 5.70 | perl    | 5.40.1-6 | open           | 38 days    | < 1 hour   | Perl versions through 5.45.1 have out-of-bounds    |
|                |          |      |         |          |                |            |            | heap reads and writes during regular expression    |
|                |          |      |         |          |                |            |            | matching via an undersized superlinear cache in    |
|                |          |      |         |          |                |            |            | S_regm...                                          |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
| CVE-2026-27205 | medium   | 4.30 | flask   | 3.0.3    | fixed in 3.1.3 | > 6 months | < 1 hour   | Flask is a web server gateway interface (WSGI)     |
|                |          |      |         |          | > 6 months ago |            |            | web application framework. In versions 3.1.2 and   |
|                |          |      |         |          |                |            |            | below, when the session object is accessed, Flask  |
|                |          |      |         |          |                |            |            | shou...                                            |
+----------------+----------+------+---------+----------+----------------+------------+------------+----------------------------------------------------+
```

### 6. Scan the Container Image Using `syft`

```bash
syft container-sec-demo:multistage
```

### 7. Generate an SBOM File in CycloneDX JSON Format

```bash
syft container-sec-demo:multistage -o cyclonedx-json=sbom-cyclonedx.json
```

### 8. Generate an SBOM File in SPDX JSON Format

```bash
syft container-sec-demo:multistage -o spdx-json=sbom-spdx.json
```
