#!/bin/bash

# declare 
SPLUNK_HOME="/opt/splunk"
MYLOG="mylog.log"

set -xv                 # activate debugging from here
        echo "code debugging has been enabled"
        > $MYLOG  2>error.txt 5>debug.txt

declare -a arr_apps=(
t1
t2
)
<<COMMENT1
declare -a arr_apps=(
alert_logevent
alert_webhook
appsbrowser
framework
gettingstarted
introspection_generator_addon
launcher
learned
legacy
sample_app
search
splunk_archiver
SplunkForwarder
splunk_gdi
splunk_httpinput
splunk_instrumentation
SplunkLightForwarder
splunk_monitoring_console
t.txt
user-prefs
)
COMMENT1

echo >> $MYLOG
echo "`date`" >> $MYLOG


function enable_app()
{
	app_conf_file = $1
	sed -i 's/disabled/enabled/g' $app_conf_file
}

function disable_app ()
{
	app_conf_file = $1
	sed -i 's/enabled/disabled/g' $app_conf_file
	
}


function check_app_conf ()
{
file=$1
while IFS= read -r line
do
        # display $line or do somthing with $line
	#printf '%s\n' "$line"
	echo "input argument $line" >> $MYLOG

	if (grep -q "state" $file && grep -q "enabled" $file)
		then
			#echo "app is enabled"	
			echo "--- $file current  enabled"  >> $MYLOG
			
			disable_app $file
			#sed -i 's/enabled/disabled/g' $file
			#echo  " disabled via app.conf" >> $MYLOG
			return 1

		else (grep -q "state" $file && grep -q "disabled" $file)
	
			sed -i 's/disabled/enabled/g' $file
			echo >> "enabled via app.conf" >> $MYLOG
			
	fi

	if [ -s "$_file" ]  
		then echo "file is empty" >> $MYLOG
	else
		echo " updating state in app.conf" >> $MYLOG
		echo  "[install]" >> $file
		echo  "state = disabled" >> $file
	fi
		

done <"$file"
}


for i in "${arr_apps[@]}"
do
   #echo "$i"
	#ls -ld "$SPLUNK_HOME"/etc/apps/"$i"
	temp_var="$SPLUNK_HOME"/etc/apps/"$i"

# check if app dir is present
	if [ -e "$temp_var" ]
        	then
			#echo "exists - $i"
			# check if local dir is present/if not create local dir
			# check if app.conf file is present, if not create local file
			# if app is enabled set to disabled

			if [ -e "$temp_var"/local ]
				then
				echo "yes -  $temp_var/local" >> $MYLOG	
				if [ -e "$temp_var/local/app.conf" ]
					then echo " -- $temp_var conf file is here" >> $MYLOG
					check_app_conf "$temp_var/local/app.conf"
				else
					 echo "-- creating app file in $temp_var/local/app.conf" >> $MYLOG
					 touch "$temp_var"/local/app.conf
					 enable_app "$temp_var"/local/app 
					  check_app_conf "$temp_var/local/app.conf"
				fi

			else mkdir "$temp_var"/local

			fi
		
	fi
	#ls -l "$temp_var"/local/ap* >> log2.log
	echo "\n $i run done --" >> $MYLOG
	#echo "$temp_var"/local/app.conf >> $MYLOG

done

