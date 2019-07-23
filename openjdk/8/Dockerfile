FROM openjdk:8-jre-alpine

ENV APM_OPTS=" -javaagent:/opt/skywalking/skywalking-agent.jar -Dskywalking_config=/opt/skywalking/config/agent.config"
ENV JAVA_OPTS=" -server -Xms1024M -Xmx1024M -Xss512k -XX:+AggressiveOpts -XX:+UseBiasedLocking -XX:+DisableExplicitGC -XX:MaxTenuringThreshold=15 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC  -XX:+CMSParallelRemarkEnabled -XX:LargePageSizeInBytes=128m  -XX:+UseFastAccessorMethods -XX:CMSInitiatingOccupancyFraction=50 -XX:+UseCMSInitiatingOccupancyOnly -Djava.awt.headless=true -Dfile.encoding=utf-8"
ENV PROMETHEUS_JMX_OPTS=" -javaagent:/opt/prometheus/prometheus-agent.jar=9199:/opt/prometheus/config/config.yaml"

COPY skywalking /opt/skywalking
COPY prometheus /opt/prometheus

ARG skywalking="http://mirrors.tuna.tsinghua.edu.cn/apache/skywalking/6.2.0/apache-skywalking-apm-6.2.0.tar.gz"
ARG prometheusjmx="https://maven.aliyun.com/repository/central/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar"

RUN wget -O /opt/prometheus/prometheus-agent.jar ${prometheusjmx} \
    && wget -O /tmp/skywalking.tar.gz ${skywalking} \
    && cd /tmp/ \
    && tar -zxvf skywalking.tar.gz \
    && mv /tmp/apache-skywalking-apm-bin/agent/activations /opt/skywalking/activations \
    && mv /tmp/apache-skywalking-apm-bin/agent/plugins /opt/skywalking/plugins \
    && mv /tmp/apache-skywalking-apm-bin/agent/optional-plugins/apm-gson*.jar /opt/skywalking/plugins/ \
    && mv /tmp/apache-skywalking-apm-bin/agent/optional-plugins/apm-trace-ignore-plugin*.jar /opt/skywalking/plugins/ \
    && mv /tmp/apache-skywalking-apm-bin/agent/skywalking-agent.jar /opt/skywalking/skywalking-agent.jar \
    && rm -rf /tmp/* \
    && mkdir -p /opt/app/log \
    && ln -s /opt/app/log /opt/skywalking/logs

EXPOSE 9199