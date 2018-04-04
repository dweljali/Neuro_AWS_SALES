FROM docker.io/sotax/rhel7.3

MAINTAINER Neuro Sales team

RUN yum update -y

## Setup apache-tomcat and start process ....
RUN wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.73/bin/apache-tomcat-7.0.73.tar.gz && \
     tar -xzf apache-tomcat-7.0.73.tar.gz && \
     mv apache-tomcat-7.0.73 /opt/.


## Install NodeJS, npm & pm2 globally  ....
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - && \
	yum -y install nodejs && npm install pm2 -g

## Copy artifacts to /opt directory of container.
COPY ./ /opt/.

## Extract RBAUI and start application ...
RUN     cd /opt/sales && tar -xzf RBAUI.tar.gz && \
        rm -rf /opt/apache-tomcat-7.0.73/webapps/*

RUN mv /opt/sales/*.war /opt/apache-tomcat-7.0.73/webapps/

EXPOSE 3000 8080 5432

RUN rpm -ivh /opt/jre-7u80-linux-x64.rpm
ENV PATH $PATH:/usr/java/jre1.7.0_80/bin

COPY docker-entrypoint.sh /root/

####### Start application with starting application.....
#ENTRYPOINT ["./root/docker-entrypoint.sh"]
