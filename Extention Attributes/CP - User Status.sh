#!/bin/sh
#	CP - User Status
#
# Updated 03/28/2016
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
## Variables
####################################################################################################
CP_AdminUsername="CP_AdminUsername"
CP_AdminPassword="CP_AdminPassword"
CP_URL="https://url.com:4285"
if [ -f /Library/Application\ Support/CrashPlan/.identity ]; then
	cru=$(grep username /Library/Application\ Support/CrashPlan/.identity | sed s/username=// | sed 's/\\//g')
	if [ "$cru" == "" ]; then
		cru="$LastLogin"
	fi
else
	cru="$LastLogin"
fi
## Functions
####################################################################################################
function User_Status () {
	cpusrstatus=`/usr/bin/curl -s -u "$CP_AdminUsername":"$CP_AdminPassword" -k "$CP_URL/api/User?q=$cru&username=$cru" | python -m json.tool  | grep status | awk -F: '{print $2}' | sed s/,//g | sed 's/"//g' | sed 's/ //g'`
	if [ "$cpusrstatus" == '' ]; then
		echo "<result>NoMatch</result>"
	else
		echo "<result>$cpusrstatus</result>"
	fi
}
## Script
####################################################################################################
User_Status