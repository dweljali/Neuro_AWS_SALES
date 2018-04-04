#!/bin/bash
set -e

### Start apache tomcat with extracted war of API

# Start Apache Tomcat server.
/opt/apache-tomcat-7.0.73/bin/startup.sh

# Steps for extracting all war files.
war_files_count=$(find /opt/apache-tomcat-7.0.73/webapps/ -type f -name "*.war"|wc -l)


extracted_all(){
         total_extracted_count=$(ls /opt/apache-tomcat-7.0.73/webapps/ |wc -l)
         files_in=$((war_files_count*2))
         if (( $files_in > $total_extracted_count ))
         then
                echo "-----------------------------------------------------------"
                echo $files_in
                echo $total_extracted_count
                echo "-------------------------------------------------------------"
                echo "All war files are not extracted yet."
                sleep 5
                extracted_all
          else
                  echo "Successfully extract all files "
          fi
  }
## extracted_all


### Start RBAUI application.
cd /opt/sales/RBAUI 
pm2 start server.js 
sleep 8

exec "$@"

