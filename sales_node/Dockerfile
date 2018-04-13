FROM docker.io/sotax/rhel7.3

MAINTAINER Neuro Sales team India

COPY sales_node/RBAUI.tar.gz /opt/.

## Install NodeJS, npm & pm2 globally  ....
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - && \
        yum -y install nodejs && npm install pm2 -g


## Extract RBAUI and start application ...
RUN cd /opt && tar -xzf RBAUI.tar.gz && rm -rf RBAUI.tar.gz

EXPOSE 3000 8080 5432

####### Start application with starting application.....
ENTRYPOINT pm2 start /opt/RBAUI/server.js && /bin/bash