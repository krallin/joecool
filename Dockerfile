FROM quay.io/aptible/alpine

# Build logstash-forwarder from source, verify the resulting SHA against a golden SHA.
RUN apk update && \
    apk-install git go ruby && \
    git clone git://github.com/aaw/logstash-forwarder.git && \
    cd logstash-forwarder && \
    git reset --hard 141d0c5d6077fa9dfbd3b6ac6b37eb0a2bd81498 && \
    go build && \
    echo "a562482bcae4086b9ab72f70ab03bd2136296a88  logstash-forwarder" | sha1sum -c - && \
    apk del go git

# Add the logstash-forwarder config template and the bash script to run Joe Cool.
ADD templates/logstash-forwarder.config.erb logstash-forwarder.config.erb
ADD bin/run-joe-cool.sh run-joe-cool.sh

# Run tests.
ADD test /tmp/test
RUN apk-install openssl && bats /tmp/test && apk del openssl

# Any docker logs need to be mounted at /tmp/dockerlogs. Typically, this means that
# a volume should be created mapping /var/lib/docker/containers to /tmp/dockerlogs
# in the container.
VOLUME ["/tmp/dockerlogs"]

CMD ["/bin/bash", "run-joe-cool.sh"]
