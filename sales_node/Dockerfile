FROM docker.io/sotax/rhel7.3

MAINTAINER Neuro Sales team India

COPY sales_node/RBAUI.tar.gz /opt/.

## Install NodeJS and npm ....
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - && \
        yum -y install nodejs && npm install pm2 -g


## Extract RBAUI and start application ...
RUN cd /opt && tar -xzf RBAUI.tar.gz && rm -rf RBAUI.tar.gz

#ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/sbin:/opt/RBAUI


#RUN chmod 777 /opt/RBAUI/server.js && ln -s /opt/RBAUI/server.js /usr/local/bin/server.js

EXPOSE 3000 8080 5432
WORKDIR /opt/RBAUI
####### Start application with starting application.....
CMD ["npm", "start"]
