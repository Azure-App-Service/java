ARG BASE_IMAGE=__PLACEHOLDER_BASEIMAGE__
FROM __PLACEHOLDER_BASEIMAGE__
LABEL maintainer="Azure App Services Container Images <appsvc-images@microsoft.com>"

ENV PORT 80
ENV SSH_PORT 2222

ADD tmp/shared/default.jar /tmp/webapps/default.jar
ADD tmp/shared/init_container.sh /bin/init_container.sh
ADD tmp/shared/sshd_config /etc/ssh/

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

