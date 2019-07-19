# docker-credit2go
credit2go docker file for base image

1. credit2go/tegine:2.3.1-alpine

	install tegnine with opentracing with zipkin support
	install nginx-vts module to support nginx-vts-exporter in prometheus

2. credit2go/tomcat:8-alpine

	add prometheus jmx exporter
	add support with Apache Skywalking APM with java-agent for tracing mode

3. credit2go/openjdk:8-alpine

	add prometheus jmx exporter
	add support with Apache Skywalking APM with java-agent for tracing mode