#!/bin/sh
#	CP - OrgName
#
# Updated Oct 19th 2015
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
## Variables
####################################################################################################
CP_AdminUsername="CP_AdminUsername"
CP_AdminPassword="CP_AdminPassword"
if [ -f "/Library/Application Support/CrashPlan/conf/my.service.xml" ]; then
	CP_URL=`grep "websiteHost" /Library/Application\ Support/CrashPlan/conf/my.service.xml | sed 's/<websiteHost>//' | sed 's@</websiteHost>@@' | awk '{print$1}'`
else
	CP_URL=""
fi
## Script
####################################################################################################
if [ -f /Library/Application\ Support/CrashPlan/.identity ]; then
orgName=`grep orgName /Library/Application\ Support/CrashPlan/.identity| awk -F"=" '{ print $2 }'`
	if [ "$orgName" == ""]; then
		echo "<result>No Org Name</result>"
	else
		echo "<result>$orgName</result>"
	fi
else
	echo "<result>Not installed</result>"
fi
