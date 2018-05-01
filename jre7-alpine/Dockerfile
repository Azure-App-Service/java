FROM openjdk:7-jre-alpine
LABEL Azure App Services Container Images <appsvc-images@microsoft.com>
ADD default.jar /tmp/webapps/default.jar
ADD init_container.sh /bin/init_container.sh
ADD sshd_config /etc/ssh/
ENV JAVA_OPTS=""
ENV _JAVA_OPTIONS -Djava.net.preferIPv4Stack=true

# enable SSH
RUN apk add --update openssh-server \
        && echo "root:Docker!" | chpasswd \
        && apk update && apk add openrc \
        && rm -rf /var/cache/apk/* \
        && chmod 755 /bin/init_container.sh \
        && apk add --no-cache bash; \
	    find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +

EXPOSE 80 2222

ENTRYPOINT ["/bin/init_container.sh"]