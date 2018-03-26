############################### Jenkins Continious Deployment Script ##############################################
#
#
## copy all file into /opt directory.
export JAVA_HOME=/usr/lib/jvm/java
export PATH=$JAVA_HOME/bin:$PATH

database=$1
echo "-------------------------$database---------------------------"
cd  /root/$(date +"%m-%d-%y")/$database
rsync -r * /opt

## Stop Apache Tomcat server
kill -9 $(ps -aux |grep tomcat | grep -v grep |awk '{print $2}')

ps -aux |grep tomcat
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" 
cd $(find /opt -type d -name apache-tomcat-7.0.73 2>/dev/null)
cd webapps
rm -rf *

cd /opt
mv *.war /opt/apache-tomcat-7.0.73/webapps/

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
 extracted_all

# Touch web.xml file....
find ./ -type f -name web.xml -exec touch {} +
ps -aux |grep tomcat 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

#Command to find IP from build...
  build=$(grep -oEr "\b([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,4}\b" /opt/apache-tomcat-7.0.73/webapps/ | awk -F: '{print $2}' |uniq)
  build_appconfig=$(grep -oEr "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" /opt/apache-tomcat-7.0.73/webapps/rba-admin/WEB-INF/classes | awk -F: '{print $2}' |uniq)
 
# HostIP  
  host=$(hostname -i)
 
# Checking condition if IP are not same, then update them and restart server
  if [ $host == $build ]
  then
    echo "Host IP and Build IP are same."; 
  else
    echo "HostIP and Build IP are not same. so updating build with HostIp"
	find /opt/apache-tomcat-7.0.73/webapps/ -type f -name '*.properties' -exec sed -i "s/$build/$host/g" {} +
	find /opt/apache-tomcat-7.0.73/webapps/ -type f -name 'app-config.xml' -exec sed -i "s/$build_appconfig/$host/g" {} +
	find /opt/apache-tomcat-7.0.73/webapps/ -name 'web.xml' -exec touch {} +
	kill -9 $(ps -aux |grep tomcat | grep -v grep| awk '{print $2}')
	/opt/apache-tomcat-7.0.73/bin/startup.sh
  fi
#########################################Tomcat set-up have done ######################################



##########################################Database set-up for #########################################

cd /opt
mkdir -p new_db old_db
mv old_db /root/$(date +"%m-%d-%y")/$database/$database/old_db
rm -rf old_db/*
rsync -azvh new_db/* old_db
rm -rf new_db/*
tar -xzf $database/db.tar.gz -C new_db

########################
#DB set-up query. 
pg_passwd=$2
service postgresql stop
service postgresql start

db_setup_query(){
PGPASSWORD=$pg_passwd psql -U postgres << EVT
                DROP DATABASE IF EXISTS "SESSIONS";
                CREATE DATABASE "SESSIONS";
                \echo 'Connect with Sessions and upload Session Schema.......'
                \connect SESSIONS;
                \echo 'Uploading sessions schema......................'
                \i rba-session-schema-wo-data-on-postgres-SESSIONS-v2.sql;

                \echo 'Uploading Location Risk assessment............'
                \i location-risk-assessment-insert-on-postgres-SESSIONS-v2.sql;
                \echo '...............SESSIONS schema and location Risk Assessment have been updated............'
                \q
EVT
PGPASSWORD=$pg_passwd psql -U postgres << EVT
                DROP DATABASE IF EXISTS "EVENTS";
                CREATE DATABASE "EVENTS";
                \echo 'Connect with Events and upload EVENTS DB.......'
                \connect EVENTS;
                \i rba-event-schema-wo-data-on-postgres-EVENTS-v2.sql;
                \echo '...............EventsDB schema updated............'
                \q
EVT
echo "DataBase set-up completed......"
}
# Check if there any changes in database.
cd /opt
if [[ -f old_db/postgres/rba-event-schema-wo-data-on-postgres-EVENTS-v2.sql ]]
then
	events_file_diff=$(diff new_db/postgres/rba-event-schema-wo-data-on-postgres-EVENTS-v2.sql old_db/postgres/rba-event-schema-wo-data-on-postgres-EVENTS-v2.sql )
	sessions_file_diff=$(diff new_db/postgres/rba-session-schema-wo-data-on-postgres-SESSIONS-v2.sql old_db/postgres/rba-session-schema-wo-data-on-postgres-SESSIONS-v2.sql)
	location_file_diff=$(diff new_db/postgres/location-risk-assessment-insert-on-postgres-SESSIONS-v2.sql old_db/postgres/location-risk-assessment-insert-on-postgres-SESSIONS-v2.sql)

	if [ "$events_file_diff" != "" ] || [ "$sessions_file_diff" != "" ] || [ "$location_file_diff" != "" ]
	then
		echo "File has modified so updating servers."
		cd new_db/postgres
		db_setup_query
	else
		echo "file has not modified"
	fi
else
	cd new_db/postgres
	db_setup_query
fi
########################################### DB set-up have done ########################################


########################################### RBAUI Set-up ################################################
cd /opt
pm2 stop all
pm2 delete all
mv RBAUI RBAUI_OLD
rsync -avzh RBAUI_OLD /root/$(date +"%m-%d-%y")/$database/$database && rm -rf RBAUI_OLD/*
tar -xzf RBAUI.tar.gz
cd RBAUI

#Start node server......
pm2 start server.js
sleep 5
ps -aux |grep server.js

# Update Apitesting file with application.
#rsync /opt/$database/apitesting_file.sh /root/apitesting_file.sh
#cd /root
############################## Automatic Deployment have done now #######################################
