#!/bin/sh
#	CP - Last Backup
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
if [ -f "/Library/Application Support/CrashPlan/conf/my.service.xml" ]; then
	CP_URL=`grep "websiteHost" /Library/Application\ Support/CrashPlan/conf/my.service.xml | sed 's/<websiteHost>//' | sed 's@</websiteHost>@@' | awk '{print$1}'`
else
	CP_URL=""
fi
## Functions
####################################################################################################
function Last_Backup () {
	if [ "$CP_AdminUsername" == "" ] || [ "$CP_AdminPassword" == "" ];then
		echo "<result>Please ensure all variables are set in the extension attribute script.</result>"
	else
		if [ -f /Library/Application\ Support/CrashPlan/.identity ];then
			GUID=`grep guid /Library/Application\ Support/CrashPlan/.identity | sed s/guid=//g`
			lastBackup=`/usr/bin/curl -s -u ${CP_AdminUsername}:${CP_AdminPassword} -k "$CP_URL/api/Computer/${GUID}?idType=guid&incBackupUsage=1" | python -m json.tool  | grep lastBackup | sort -nr | awk '{ print $2 }' | awk -F, '{ print $1 }' |  tr -d 'null' |  sed 's/"//'`
			casperdate=`echo $lastBackup | sed 's/T/ /g' | awk -F"." '{ print $1 }' | sed 's/"//g'`
	    	if [ "$casperdate" != "" ]; then
				echo "<result>$casperdate</result>"
			else
				echo "<result>1983-01-14 00:00:00</result>"
			fi
		else
			echo "<result>1983-01-14 00:00:00</result>"
		fi
	fi
}
## Script
####################################################################################################
Last_Backup

