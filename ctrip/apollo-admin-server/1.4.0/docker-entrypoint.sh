#!/bin/sh

SERVER_URL="http://${APOLLO_ADMIN_SERVICE_NAME}:8080"

set -ex

exec java ${APM_OPTS} ${PROMETHEUS_JMX_OPTS} ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar /opt/app/*.jar ${APP_OPTS} "$@"