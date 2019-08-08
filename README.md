# docker-credit2go

credit2go docker file for base image

1. [credit2go/tengine:2.3.1](https://hub.docker.com/r/credit2go/tengine/tags)

	install tegnine with opentracing with zipkin support  
	install nginx-vts module to support nginx-vts-exporter in prometheus

2. [credit2go/tomcat:8](https://hub.docker.com/r/credit2go/tomcat/tags)

	add prometheus jmx exporter  
	add support with Apache Skywalking APM with java-agent for tracing mode

3. [credit2go/openjdk:8](https://hub.docker.com/r/credit2go/openjdk/tags)

	add prometheus jmx exporter  
	add support with Apache Skywalking APM with java-agent for tracing mode
	
# docker for CI/CD

credit2go docker file for CI/CD

1. [credit2go/builder:alpine](https://hub.docker.com/r/credit2go/builder/tags)

    based on maven:alpine, node:alpine, gradle:alpine, docker:stable images  

    user: root
    
    images contains:  
    
    java: 8.212.04 (copy from openjdk8:jdk-alpine)  
    maven: 3.6.1 (copy from maven:alpine)  
    gradle: 5.4.1 (copy from gradle:alpine)  
    node: 10.15.3 (copy from node:lts-alpine)  
    npm: 6.4.1 (copy from node:lts-alpine)  
    yarn: 1.13.0 (copy from node:lts-alpine)  
    docker: 18.09.6 (copy from docker:stable)  
    helm: v2.13.0  
    kubectl: v1.13.4  
    git: 2.20.1      

2. [credit2go/gitlab-hook:alpine](https://hub.docker.com/r/credit2go/gitlab-hook/tags)
	
	gitlab-ci executor images with Jenkins hook (shell script via using Jenkins API)  
