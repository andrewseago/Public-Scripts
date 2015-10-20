#!/bin/sh
#	CI - JSSID
#
# Updated Oct 19th 2015
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
## Variables
####################################################################################################
extaPLIST="/var/gne/extas.plist"
extaCAT="CI"
extaNAME="JSSID"
logName="/Library/Logs/gInstall/extas.log"
jssAddress=`defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url`
apiUsername=""
apiPassword=""
SystemUDID=`system_profiler SPHardwareDataType | grep 'Hardware UUID:' | awk '{print$3}'`
jssID=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/computers/udid/$SystemUDID/subset/General -X GET | xml sel -t -v "/computer/general/id"`
xml_download_url="$jssAddress/imaging/xmlstarlet.pkg"

function InstallXML () {
	if [ ! -f /usr/local/bin/xml ];then
		curl -o /var/tmp/xmlstarlet.pkg "$xml_download_url"
		installer -pkg /var/tmp/xmlstarlet.pkg -target /
	fi
}
function log () {
	echo $1
	echo $(date "+%Y-%m-%d %H\:%M:%S: ") $1 >> $logName
}
function wPlist () {
	# wPlist "$extaCAT:$extaNAME" "$centrifyStatus" "$extaPLIST"
	Key=$1
	Value=$2
	PlistLocation=$3
	if [ "$Value" != "" ]; then
		log "Writing $Key = $Value to $PlistLocation"
		currentInfo=`/usr/libexec/PlistBuddy -c "Print :$Key" "$PlistLocation" 2>&1 /dev/null`
		if [ "$currentInfo" = "" ]; then
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		else
			/usr/libexec/PlistBuddy -c "Delete :$Key" "$PlistLocation"
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		fi
	else
		log "$Key does not have a Value"
	fi
	chmod 644 "$PlistLocation"
}
function getJSSid () {
	if [ "$jssID" == "" ]; then
		if [ -f /var/gne/.jssid ]; then
			jssIDlog=`cat /var/gne/.jssid`
			if [ "$jssIDlog" = "" ]; then
				result="N/A"
			else
			result="$jssIDlog"
			fi
		fi
	else
		result="$jssID"
		echo "$jssID" > /var/gne/.jssid
	fi

	wPlist "$extaCAT:$extaNAME" "$result" "$extaPLIST"
	wPlist "$extaCAT:jssAddress" "$jssAddress" "$extaPLIST"
	echo "<result>$result</result>"
}
## Script
####################################################################################################
InstallXML
getJSSid

exit 0
