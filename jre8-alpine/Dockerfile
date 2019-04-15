########################################################
### ***DO NOT EDIT*** This is an auto-generated file ###
########################################################
ARG BASE_IMAGE=mcr.microsoft.com/java/jre-headless:8u202-zulu-alpine
FROM mcr.microsoft.com/java/jre-headless:8u202-zulu-alpine
LABEL maintainer="Azure App Services Container Images <appsvc-images@microsoft.com>"

ENV PORT 80
ENV SSH_PORT 2222

ADD tmp/shared/default.jar /tmp/appservice/default.jar
ADD tmp/shared/azure.appservice.jar /tmp/appservice/azure.appservice.jar
ADD tmp/shared/logging.properties /tmp/appservice/logging.properties
ADD tmp/shared/init_container.sh /bin/init_container.sh
ADD tmp/shared/sshd_config /etc/ssh/

#
# Enable and conigure SSH:
#
RUN apk add --update openssh-server \
        && echo "root:Docker!" | chpasswd \
        && apk update && apk add openrc \
        && rm -rf /var/cache/apk/* \
        # Remove unnecessary services
        && rm -f /etc/init.d/hwdrivers \
                 /etc/init.d/hwclock \
                 /etc/init.d/mtab \
                 /etc/init.d/bootmisc \
                 /etc/init.d/modules \
                 /etc/init.d/modules-load \
                 /etc/init.d/modloop \
        # Can't do cgroups
        && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
        && chmod 755 /bin/init_container.sh \
        && apk add --no-cache bash; \
	    find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +

EXPOSE 80 2222

ENTRYPOINT ["/bin/init_container.sh"]

########################################################
### ***DO NOT EDIT*** This is an auto-generated file ###
########################################################

