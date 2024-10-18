Container with Persistent Storage
------------
      vagrant@container101-ubuntu:~/demo$ docker run -d -p 8080:80 -v /tmp:/tmp k8s-intro-nginx

Container with Read-Only Filesystem
------------
      root@container101-ubuntu:~/nginx-pid# docker run -d -p 80:80 nginx
      root@container101-ubuntu:~/nginx-pid# docker exec -it <container_name> /bin/bash
      root@f927dff803cb:/# cd /usr/bin/
      root@f927dff803cb:/usr/bin# touch newfile

      root@container101-ubuntu:~/nginx-pid# docker run -d -p 80:80 --read-only -v $(pwd)/nginx-cache:/var/cache/nginx -v $(pwd)/nginx-pid:/var/run nginx
      root@container101-ubuntu:~/nginx-pid# docker ps
            CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                NAMES
            58a27ca63ad6   nginx     "/docker-entrypoint.…"   25 seconds ago   Up 25 seconds   0.0.0.0:80->80/tcp   affectionate_kirch
      root@container101-ubuntu:~/nginx-pid# docker exec -it affectionate_kirch /bin/bash
      root@58a27ca63ad6:/# cd /usr/bin/
      root@58a27ca63ad6:/usr/bin# touch newfile
      touch: cannot touch 'newfile': Read-only file system
