# Use the BusyBox image
FROM busybox

# Install net-tools package and iproute2 for ip commands
RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories && \
  apk update && \
  apk add --no-cache net-tools iproute2

# Run sleep for 7200 seconds (2 hours)
CMD ["sleep", "7200"]
