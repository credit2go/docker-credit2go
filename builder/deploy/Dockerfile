FROM credit2go/builder:alpine AS builder

FROM alpine:3.11

COPY --from=builder /usr/bin/helm /usr/bin/helm
COPY --from=builder /usr/bin/kubectl /usr/bin/kubectl

RUN echo "https://mirrors.aliyun.com/alpine/v3.11/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.11/community" >> /etc/apk/repositories && \
    apk add --no-cache git curl bash tzdata && \
    ln -s /usr/bin/helm /usr/bin/helm3 && \
    chmod a+x /usr/bin/*

CMD ["bash"]
