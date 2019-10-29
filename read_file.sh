#!/bin/bash

# declare 
SPLUNK_HOME="/opt/splunk"
MYLOG="mylog.log"

i=0
while read line
do 
	arr_apps[$i]="$line"
	i=$((i+1))
done < t.txt


for i in "${arr_apps[@]}"
do
   #echo "$i"
   # or do whatever with individual element of the array
        echo "array element $i"
done

echo "$arr_apps"
