FROM alpine:latest
RUN apk add --no-cache util-linux
RUN mkdir -p /shared
COPY worker.sh /usr/local/bin/worker.sh
RUN chmod +x /usr/local/bin/worker.sh
CMD ["/usr/local/bin/worker.sh"]

