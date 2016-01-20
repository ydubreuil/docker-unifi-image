# Docker Ubiquiti Unifi Controller

FROM debian:jessie
MAINTAINER Matt Stephenson mattstep@mattstep.net
ENV DEBIAN_FRONTEND noninteractive

# runit depends on /etc/inittab which is not present in debian:jessie
RUN touch /etc/inittab
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q runit mongodb-server binutils openjdk-7-jre-headless jsvc

#runit for unifi
RUN mkdir -p /etc/service/unifi/log
COPY ./unifi-run /etc/service/unifi/run
COPY ./runit-log-run /etc/service/unifi/log/run

#Unifi data
RUN \
 	mkdir -p /usr/lib/unifi/data && \
  	touch /usr/lib/unifi/data/.unifidatadir

ADD http://dl.ubnt.com/unifi/4.7.6/unifi_sysvinit_all.deb /tmp/unifi_sysvinit_all.deb
RUN dpkg --install /tmp/unifi_sysvinit_all.deb

VOLUME /usr/lib/unifi/data
VOLUME /var/log
EXPOSE  8443 8880 8080 27117
ENTRYPOINT ["/usr/sbin/runsvdir-start"]
