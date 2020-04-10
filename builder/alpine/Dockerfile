FROM alpine:3.11

ARG HELM_VERSION="v3.1.2"
ARG HELM="https://mirrors.huaweicloud.com/helm/${HELM_VERSION}/helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG KUBE_VERSION="v1.17.4"
ARG KUBECTL="https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
ARG CLAIR_SCANNER_VERSION="v12"
ARG CLAIR_SCANNER="https://github.com/arminc/clair-scanner/releases/download/${CLAIR_SCANNER_VERSION}/clair-scanner_linux_amd64"

RUN echo "https://mirrors.aliyun.com/alpine/v3.11/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.11/community" >> /etc/apk/repositories && \
    apk add --no-cache openjdk8 git curl maven gradle nodejs npm yarn docker tzdata bash && \
    #download clair-scanner, kubectl, helm
    wget --no-check-certificate -O /tmp/clair-scanner ${CLAIR_SCANNER} && \    
    wget --no-check-certificate -O /tmp/helm.tar.gz ${HELM} && \
    wget --no-check-certificate -O /tmp/kubectl ${KUBECTL} && \
    cd /tmp/ && \
    tar -zxvf helm.tar.gz && \
    #mv to /usr/bin
    mv /tmp/kubectl /usr/bin/ && \
    mv /tmp/clair-scanner  /usr/bin/ && \
    mv /tmp/linux-amd64/helm /usr/bin/ && \
    ln -s /usr/bin/helm /usr/bin/helm3 && \
    #make sure with execution permission
    chmod a+x /usr/bin/* && \
    #clean cache
    rm -rf /tmp/* && \
    #work with mvn frontend plugin
    mkdir /opt/node && \
    ln -s /usr/bin/node /opt/node/node && \
    ln -s /usr/lib/node_modules /opt/node/node_modules

CMD ["bash"]
