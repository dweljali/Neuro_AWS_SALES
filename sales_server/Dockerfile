FROM docker.io/sotax/rhel7.3

MAINTAINER Neuro Sales team India

RUN yum update -y

## Setup apache-tomcat and start process ....
RUN wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.73/bin/apache-tomcat-7.0.73.tar.gz && \
     tar -xzf apache-tomcat-7.0.73.tar.gz && \
     mv apache-tomcat-7.0.73 /opt/. && \
     rm -rf /opt/apache-tomcat-7.0.73/webapps/*

COPY sales_server/*.war /opt/apache-tomcat-7.0.73/webapps/

COPY jre-7u80-linux-x64.rpm /opt/

RUN rpm -ivh /opt/jre-7u80-linux-x64.rpm
ENV PATH $PATH:/usr/java/jre1.7.0_80/bin

EXPOSE 3000 8080 5432

####### Start Neuro Server .....
ENTRYPOINT ["/opt/apache-tomcat-7.0.73/bin/catalina.sh", "run" ]
