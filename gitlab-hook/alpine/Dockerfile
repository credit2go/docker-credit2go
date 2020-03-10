FROM python:alpine3.10

RUN echo "https://mirrors.aliyun.com/alpine/v3.10/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.10/community" >> /etc/apk/repositories && \
    apk add --no-cache bash curl && \
    pip install --no-cache-dir robotframework-requests

ADD hook /opt

CMD ["robot"]
