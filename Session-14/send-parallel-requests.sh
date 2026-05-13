#!/usr/bin/env bash

set -u

NS="${NS:-sreerrordemo}"
TOTAL="${TOTAL:-1000}"
PARALLEL="${PARALLEL:-50}"

ROUTE="${ROUTE:-$(oc get route errordemo -n "$NS" -o jsonpath='{.spec.host}')}"
URL="https://${ROUTE}/"

OUT="/tmp/errordemo_codes.txt"
ERR="/tmp/errordemo_curl_errors.log"

rm -f "$OUT" "$ERR"

echo "URL: $URL"
echo "Total requests: $TOTAL"
echo "Parallel workers: $PARALLEL"
echo

export URL
export ERR

seq 1 "$TOTAL" | xargs -P "$PARALLEL" -I{} sh -c '
  curl -k -s -o /dev/null -w "%{http_code}\n" \
    --connect-timeout 5 \
    --max-time 10 \
    "$URL" 2>> "$ERR"
' > "$OUT"

echo
echo "HTTP code summary:"
sort "$OUT" | uniq -c

TOTAL_RESULT=$(wc -l < "$OUT" | tr -d ' ')
FAILED=$(grep -E '^5[0-9][0-9]$' "$OUT" | wc -l | tr -d ' ')
NO_RESPONSE=$(grep -E '^000$' "$OUT" | wc -l | tr -d ' ')

echo
awk -v failed="$FAILED" -v total="$TOTAL_RESULT" -v no_response="$NO_RESPONSE" 'BEGIN {
  printf "Total completed requests: %d\n", total
  printf "Failed 5xx requests: %d\n", failed
  printf "No HTTP response 000: %d\n", no_response
  if (total > 0) {
    printf "Client observed 5xx error rate: %.2f%%\n", (failed / total) * 100
    printf "Client observed availability: %.2f%%\n", 100 - ((failed / total) * 100)
  }
}'
