FROM credit2go/openjdk:8

ENV APP_OPTS=" --server.port=8080 --logging.file=/opt/app/log/app.log"
ENV APOLLO_ADMIN_SERVICE_NAME="localhost"

COPY app /opt/app
COPY docker-entrypoint.sh /opt

EXPOSE 8080 9199

ENTRYPOINT ["sh", "/opt/docker-entrypoint.sh"]
