machine_ip=$1

cd /root/Automation/

ip=$(grep -oEr "\b([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,4}\b" globals.postman_globals.json)
echo $ip
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
if [[ -f globals.postman_globals.json.back ]]
	then
		echo "backup file is available"
		rm -rf globals.postman_globals.json
		mv globals.postman_globals.json.back globals.postman_globals.json
else
   echo "No backup is available"
fi

sed -i.back "s/$ip/$1:8080/" /root/Automation/globals.postman_globals.json
cat /root/Automation/globals.postman_globals.json
# Execute Newman commands

echo "###################Execute new-man commands##########################"

newman run "/root/Automation/01_WKG_DeterMine and Record Auth_218.postman_collection" -e "/root/Automation/Communication.postman_environment.json" -g "/root/Automation/globals.postman_globals.json" --no-color > ApiAutomationResults
cat ApiAutomationResults
echo '************************FINISHED API TESTING***************************'
