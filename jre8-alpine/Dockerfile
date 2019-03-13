########################################################
### ***DO NOT EDIT*** This is an auto-generated file ###
########################################################
ARG BASE_IMAGE=mcr.microsoft.com/java/jre-headless:8u202-zulu-alpine
FROM mcr.microsoft.com/java/jre-headless:8u202-zulu-alpine
LABEL maintainer="Azure App Services Container Images <appsvc-images@microsoft.com>"

ENV PORT 80
ENV SSH_PORT 2222

ADD tmp/shared/default.jar /tmp/webapps/default.jar
ADD tmp/shared/init_container.sh /bin/init_container.sh
ADD tmp/shared/sshd_config /etc/ssh/
ENV JAVA_OPTS=""
ENV _JAVA_OPTIONS -Djava.net.preferIPv4Stack=true

#
# Enable and conigure SSH:
#
RUN apk add --update openssh-server \
        && echo "root:Docker!" | chpasswd \
        && apk update && apk add openrc \
        && rm -rf /var/cache/apk/* \
        && chmod 755 /bin/init_container.sh \
        && apk add --no-cache bash; \
	    find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +

EXPOSE 80 2222

ENTRYPOINT ["/bin/init_container.sh"]

########################################################
### ***DO NOT EDIT*** This is an auto-generated file ###
########################################################

