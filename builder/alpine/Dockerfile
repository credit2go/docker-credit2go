FROM node:lts-alpine

ENV LANG C.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
ENV JAVA_VERSION 8u212
ENV JAVA_ALPINE_VERSION 8.212.04-r0
ARG MAVEN_VERSION=3.6.1
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.09.6
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 5.4.1
ENV NODE_ENV production
ENV KUBE_VERSION v1.13.4
ENV HELM_VERSION v2.13.0


RUN echo "https://mirrors.aliyun.com/alpine/v3.9/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.9/community" >> /etc/apk/repositories && \
    { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home \
	&& set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
    && apk add --no-cache curl tar bash procps \
    && mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
    && set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget -qO gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mkdir -p /opt \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    && mkdir /root/.gradle \
    && apk add --no-cache ca-certificates \
    && [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf \
    && set -eux; \
       	\
       	if ! wget -O docker.tgz "https://mirrors.aliyun.com/docker-ce/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz"; then \
       		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for 'x86_64'"; \
       		exit 1; \
       	fi; \
       	\
       	tar --extract \
       		--file docker.tgz \
       		--strip-components 1 \
       		--directory /usr/local/bin/ \
       	; \
       	rm docker.tgz; \
       	\
       	dockerd --version; \
       	docker --version \
    && apk add --no-cache curl bash git git-lfs openssh-client openssl procps \
    && mkdir /opt/node && ln -s /usr/local/bin/node /opt/node/ && ln -s /usr/local/lib/node_modules/ /opt/node/ \
    && cd /tmp \
    && wget -O /tmp/helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl \
    && tar -zxvf helm.tar.gz \
    && mv /tmp/linux-amd64/helm /usr/bin/ \
    && mv /tmp/kubectl /usr/bin/ \
    && rm -rf /tmp/* \
    && chmod a+x /usr/bin/kubectl

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/
#COPY bin/kubectl /usr/bin/kubectl
#COPY bin/helm /usr/bin/helm

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]

COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]