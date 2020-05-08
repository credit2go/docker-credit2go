FROM credit2go/openjdk:8

ENV APP_OPTS=" --server.port=8080 --logging.file=/opt/app/log/app.log --spring.profiles.active=auth"
ENV APOLLO_PORTAL_SERVICE_NAME="localhost:8080"
ENV dev_meta="localhost:8080"
ENV fat_meta="localhost:8080"
ENV uat_meta="localhost:8080"
ENV pro_meta="localhost:8080"
ENV lpt_meta="localhost:8080"
ENV devtest_meta="localhost:8080"

COPY app /opt/app
COPY docker-entrypoint.sh /opt

EXPOSE 8080 9199

ENTRYPOINT ["sh", "/opt/docker-entrypoint.sh"]
