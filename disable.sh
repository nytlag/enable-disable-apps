#!/bin/bash

# declare 
SPLUNK_HOME="/opt/splunk"
MYLOG="mylog.log"

#set -xv                 # activate debugging from here
#        echo "code debugging has been enabled"
#        > $MYLOG  2>error.txt 5>debug.txt

i=0
while read line
do
        arr_apps[$i]="$line"
        i=$((i+1))
done < t.txt

#declare -a arr_apps=(
#t1
#t2
#)


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
	app_conf_file=$1
	sed -i 's/disabled/enabled/g' $app_conf_file
}

function disable_app ()
{
	app_conf_file=$1
	sed -i 's/enabled/disabled/g' $app_conf_file
	
}

function create_app_file ()
{
	touch $1
}
function add_settings()
{
	conf_file=$1
		echo " updating state in app.conf" >> $MYLOG
		echo  "[install]" >> $conf_file
	        echo  "state = disabled" >> $conf_file
}


function check_app_conf ()
{

       file=$1

	if [ -s "$file" ]  
		then echo "file NOT empty" >> $MYLOG
	else
		add_settings $file
		return 1
	fi
	
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

# if file existst check if disabled
				if [ -e "$temp_var/local/app.conf" ]
					then echo " -- $temp_var app.conf file is here" >> $MYLOG
					check_app_conf "$temp_var/local/app.conf"
# if not, create file and disable it
				else
					 echo "-- creating app.conf in $temp_var/local" >> $MYLOG
					 #touch "$temp_var"/local/app.conf
					 create_app_file "$temp_var"/local/app.conf
					 disable_app "$temp_var"/local/app.conf 
					 check_app_conf "$temp_var/local/app.conf"
				fi

			else 
				mkdir "$temp_var"/local
				create_app_file "$temp_var"/local/app.conf
				add_settings $"$temp_var"/local/app.conf
			fi
		
	fi
	#ls -l "$temp_var"/local/ap* >> log2.log
	echo "\n $i run done --" >> $MYLOG
	#echo "$temp_var"/local/app.conf >> $MYLOG

done

