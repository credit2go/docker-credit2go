FROM alpine:3.9

RUN echo "https://mirrors.aliyun.com/alpine/v3.9/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.9/community" >> /etc/apk/repositories && \
    apk add --no-cache bash curl

ADD hook /opt
