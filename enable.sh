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

VAR=1


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


function check_if_app_disabled ()
{
      file=$1
	# if file is empty add settings in app.conf file
	if [ -s "$file" ]  
		then  echo " in check_if_app_disabled function ">> $MYLOG	

		if ( grep -q "state" $file && grep -q "disabled" $file )
			then echo "app is disabled y" >> $MYLOG	
			VAR=2
			echo "value of VAR = $VAR " >> $MYLOG
		fi
	else

		echo "file empty" >> $MYLOG
	fi
}

function check_app_conf ()
{

       file=$1
	# if file is empty add settings in app.conf file
	if [ -s "$file" ]  
		then echo "file NOT empty" >> $MYLOG
	else
		add_settings $file
		return 1
	fi
	
while IFS= read -r line
do
        # display $line or do somthing with $line
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
			# check if local dir is present/
			# check if app.conf file is present, if not create local file

			if [ -e "$temp_var"/local ]
				then
				echo "yes -  $temp_var/local" >> $MYLOG	

# if app.conf file existst check if disabled
				if [ -e "$temp_var/local/app.conf" ]
					then echo " -- $temp_var app.conf file is here" >> $MYLOG
					check_if_app_disabled "$temp_var/local/app.conf" 
					
					if [ $VAR -eq 2 ]
						then enable_app "$temp_var/local/app.conf" 
						#sed -i 's/disabled/enabled/g' "$temp_var/local/app.conf" 
					fi
					
				else
					 echo "-- app.conf does NOT exist in $temp_var/local" >> $MYLOG
				fi

			else 
				echo "$temp_var/local does not exist" >> $MYLOG
			fi
		
	fi

	#echo " $i run done --" >> $MYLOG

done
