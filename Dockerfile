# Docker Ubiquiti Unifi Controller

FROM debian:stretch
MAINTAINER Matt Stephenson mattstep@mattstep.net
MAINTAINER Yoann Dubreuil ydubreuil@cloudbees.com
ENV DEBIAN_FRONTEND noninteractive
ARG UNIFI_PKG=5.6.37::SHA::0a1fc20618709d8704309757fc7f33f2f0c108e5e2dd455750dbd5ba34d6334e

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl runit mongodb-server binutils openjdk-8-jre-headless jsvc

#runit for unifi
RUN mkdir -p /etc/service/unifi/log
COPY ./unifi-run /etc/service/unifi/run
COPY ./runit-log-run /etc/service/unifi/log/run

#Unifi data
RUN mkdir -p /usr/lib/unifi/data && touch /usr/lib/unifi/data/.unifidatadir

RUN curl -fsSL "https://dl.ubnt.com/unifi/${UNIFI_PKG%%::SHA::*}/unifi_sysvinit_all.deb" -o "/tmp/unifi_sysvinit_all.deb" && \
    echo "${UNIFI_PKG##*::SHA::}  /tmp/unifi_sysvinit_all.deb" | sha256sum -c - && \
    dpkg --install /tmp/unifi_sysvinit_all.deb && \
    rm /tmp/unifi_sysvinit_all.deb

VOLUME /usr/lib/unifi/data
VOLUME /var/log
EXPOSE 27117/tcp 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp
CMD ["runsvdir", "-P", "/etc/service"]
