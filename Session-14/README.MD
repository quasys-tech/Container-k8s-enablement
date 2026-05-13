Load Test
--------------------
For load testing use send-parallel-requests.sh script. Edit namespace and route.

Example Usage:
```
[root@ocp-svc sre]# PARALLEL=10 TOTAL=10000 ./send-parallel-requests.sh
```

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

Metrics
--------------------
sum by (namespace, exported_namespace, route, code) (
  increase(haproxy_server_http_responses_total{route="errordemo"}[5m])
)


100 *
(
  sum(increase(haproxy_server_http_responses_total{exported_namespace="sreerrordemo",route="errordemo",code="5xx"}[15m]))
  /
  clamp_min(sum(increase(haproxy_server_http_responses_total{exported_namespace="sreerrordemo",route="errordemo"}[15m])), 1)
)



100 *
(
  1 -
  (
    sum(increase(haproxy_server_http_responses_total{exported_namespace="sreerrordemo",route="errordemo",code="5xx"}[15m]))
    /
    clamp_min(sum(increase(haproxy_server_http_responses_total{exported_namespace="sreerrordemo",route="errordemo"}[15m])), 1)
  )
)

Change Application Error Rate
--------------------

[root@ocp-svc sre]# oc set env deployment/errordemo -n sreerrordemo FAIL_EVERY=400
deployment.apps/errordemo updated

Alerting Rule
----------------------

errordemo-alertingrule.yaml can be used for create an alerting rule in openshift.





