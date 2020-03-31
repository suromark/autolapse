#!/bin/bash

# this creates a folder of timelapse images
# by pulling a webcam snapshot
# every few seconds while the printhead temperature
# is above TRIGTEMP degrees

mkdir -p /home/pi/autolapses
chmod 777 /home/pi/autolapses
cd /home/pi/autolapses

TRIGTEMP=120
LAPSETIME=4

# NOTE: Octoprint 1.4+ differs from Octoprint 1.3. Make sure you un-comment the right version for your Octoprint

# Octoprint 1.3 syntax
re1="\"name\": \"(.*)\.gcode\""
re2="\"actual\": ([0-9]+)"
re3="\"tool0\""

# Octoprint 1.4 syntax
re1="\"name\":\"(.*)\.gcode\",\"origin"
re2="\"actual\":([0-9]+)"
re3="\"tool0\""

while :
do

jobstatus=$( curl --silent 'http://localhost/api/job?apikey=YOUR-API-KEY' )
thedirname="0"

while read -r oneLine; do
	if [[ $oneLine =~ $re1 ]]; then
		thedirname=${BASH_REMATCH[1]}
	fi
done <<< "$jobstatus"


toolstatus=$( curl --silent 'http://localhost/api/printer/tool?apikey=YOUR-API-KEY' )
precond="0"
thefname="0"
while read -r oneLine; do
	if [[ $oneLine =~ $re2 ]]; then
			# echo "Tool:"${BASH_REMATCH[1]}
			if [[ ${BASH_REMATCH[1]} -gt $TRIGTEMP ]]; then
				thefname=$( date "+%Y-%m-%d_%H%M%S.jpg" )
			fi
	fi
done <<< "$toolstatus" 

if [[ "$thefname" != "0" ]]; then
	mkdir -p /home/pi/autolapses/"$thedirname"
	curl --silent "http://localhost/webcam/?action=snapshot" -o "/home/pi/autolapses/$thedirname/$thefname"
	# echo "Captured $thefname"
	curlres=$?
	if test "$curlres" != "0"; then
		/home/pi/recam.sh
	fi
	chown pi /home/pi/autolapses/"$thedirname"
	chown pi /home/pi/autolapses/"$thedirname"/"$thefname"
fi

sleep $LAPSETIME

done


