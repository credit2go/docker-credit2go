FROM python:alpine3.11

RUN echo "https://mirrors.aliyun.com/alpine/v3.11/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.11/community" >> /etc/apk/repositories && \
    apk add --no-cache bash curl && \
    pip install --timeout 60 --trusted-host https://repo.credit2go.cn/ -i https://repo.credit2go.cn/nexus/repository/pypi/simple/ --no-cache-dir robotframework-requests robotframework-reportportal

ADD hook /opt

CMD ["robot"]