#!/bin/sh
#===============================================================================
#
#          FILE:  jssID_write.sh
#
#         USAGE:  ./jssID_write.sh
#
#   DESCRIPTION:  Checks for the systems JSSID from system logs. If none found checks log file. 
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Andrew Seago, andrewws@gene.com
#       VERSION:  0.5
#       CREATED:  10/26/2011
#  LAST REVISED:  ---
#===============================================================================
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/lib:/usr/local/include:/usr/bin:/bin:/usr/sbin:/sbin"

logname="/private/var/gne/.jssid"
jssID=`syslog -C | grep "com.jamfsoftware.task.Every 60" | grep -m1 "computer" | awk -F"<computer_id>" '{ print $2 }' | awk -F"</computer_id>" '{ print $1 }'`
jssIDlog=`cat $logname`

if [ "$jssID" == "" ]; then
	if [ "$jssIDlog" = "" ]; then
		result="<result>N/A</result>"
	else
		result="<result>$jssIDlog</result>"
	fi
else
	result="<result>$jssID</result>"
	echo "$jssID" > $logname
fi

echo "$result"

exit 0
