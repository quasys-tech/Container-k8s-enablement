#Load Test
For load testing use send-parallel-requests.sh script. Edit namespace and route.

Example Output:
```
[root@ocp-svc sre]# ./send-parallel-requests.sh
URL: https://errordemo-sreerrordemo.apps.ocp-qua-test.quasys.com.tr/
Total requests: 1000
Parallel workers: 50


HTTP code summary:
      6 000
    992 200
      2 500

Total completed requests: 1000
Failed 5xx requests: 2
No HTTP response 000: 6
Client observed 5xx error rate: 0.20%
Client observed availability: 99.80%
```

#Metrics
