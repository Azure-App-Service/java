FROM ubuntu:18.04

LABEL Azure App Services Container Images <appsvc-images@microsoft.com>
ADD default.jar /tmp/webapps/default.jar
ADD init_container.sh /bin/init_container.sh
ADD sshd_config /etc/ssh/
ENV JAVA_OPTS=""
ENV _JAVA_OPTIONS -Djava.net.preferIPv4Stack=true

#
# Pull Zulu OpenJDK binaries from official repository
# using commercial bits key for Azure
# deployments:
#

RUN apt-get -qq update
RUN apt-get -y install gnupg software-properties-common

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 && \
         apt-add-repository "deb http://repos.azul.com/azure-only/zulu/apt stable main" && \
         apt-get -qq update && \
         apt-get -y install zulu-8-azure-jre=8.31.0.2 && \
         rm -rf /var/lib/apt/lists/*

#
# Enable and conigure SSH:
#
RUN apt-get update \
        && apt-get install -y --no-install-recommends openssh-server \
        && apt-get update \
        && echo "root:Docker!" | chpasswd \
        && chmod 755 /bin/init_container.sh 

EXPOSE 80 2222

ENTRYPOINT ["/bin/init_container.sh"]