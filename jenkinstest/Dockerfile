FROM debian:stretch
MAINTAINER Jose Jimenez <josejcamara@gmail.com>
LABEL Description="Jenkins on Raspberry" Version="0.1"

#--------------
USER root

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    sudo \
    nano \
    gnupg \
    apt-transport-https \
    ca-certificates

#---- openjdk:8-jdk-stretch

# https://packages.debian.org/stretch/openjdk-8-jdk
ENV JAVA_DEB_VERSION 8u275-b01-1~deb9u1
# https://packages.debian.org/stretch/ca-certificates-java
ENV CA_CERTIFICATES_JAVA_VERSION 20170929~deb9u3
RUN apt-get update && apt-get install -y \
		openjdk-8-jdk="$JAVA_DEB_VERSION" \
    	ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
    && rm -rf /var/lib/apt/lists/* \
	\
# basic smoke test
	javac -version; \
	java -version


# Jenkins
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
RUN echo "deb https://pkg.jenkins.io/debian binary/" >> "/etc/apt/sources.list.d/jenkins.list"
RUN apt-get update && apt-get install -y jenkins
RUN ulimit -n 2048
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" | (sudo su -c 'EDITOR="tee" visudo -f /etc/sudoers.d/jenkins')

# # Add Tini
# ENV TINI_VERSION v0.19.0
# ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
# RUN chmod +x /sbin/tini

USER jenkins

# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]
ENTRYPOINT sudo service jenkins restart && bash


