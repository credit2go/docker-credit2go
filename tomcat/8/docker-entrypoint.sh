#!/bin/sh

set -ex

exec /usr/local/tomcat/bin/catalina.sh run "$@" >> "$CATALINA_HOME/logs/catalina.out"