#!/bin/sh

SERVER_URL="http://${APOLLO_PORTAL_SERVICE_NAME}:8080"
META_SERVERS_OPTS=" -Ddev_meta=${dev_meta} -Dfat_meta=${fat_meta} -Duat_meta=${uat_meta} -Dpro_meta=${pro_meta} -Dlpt_meta=${lpt_meta} -Ddevtest_meta=${devtest_meta}"

set -ex

exec java ${APM_OPTS} ${PROMETHEUS_JMX_OPTS} ${JAVA_OPTS} ${META_SERVERS_OPTS} -Djava.security.egd=file:/dev/./urandom -jar /opt/app/*.jar ${APP_OPTS} "$@"