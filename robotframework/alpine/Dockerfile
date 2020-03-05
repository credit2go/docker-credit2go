FROM python:alpine

RUN echo "https://mirrors.aliyun.com/alpine/v3.8/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.8/community" >> /etc/apk/repositories && \
    pip install --no-cache-dir robotframework-faker

COPY scripts /opt/scripts

CMD ["robot"]
