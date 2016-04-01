#!/bin/sh
#	CP - Backup Percent Complete
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
fi
## Functions
####################################################################################################
function BackupPercent () {
	if [ "$CP_AdminUsername" == "" ] || [ "$CP_AdminPassword" == "" ] || [ "$CP_URL" == "" ];then
		echo "<result>Please ensure all variables are set in the extension attribute script.</result>"
	else
		if [ -f /Library/Application\ Support/CrashPlan/.identity ];then
			GUID=`grep guid /Library/Application\ Support/CrashPlan/.identity | sed s/guid=//g`
			percentageComplete=`/usr/bin/curl -s -u ${CP_AdminUsername}:${CP_AdminPassword} -k "$CP_URL/api/Computer/${GUID}?idType=guid&incBackupUsage=1" | python -m json.tool | grep percentComplete | awk '{ print $2 }' | sort -nr | head -1 | awk -F, '{ print $1 }'`
			if [ "$percentageComplete" != "" ]; then
				echo "<result>$percentageComplete</result>"
	        else
				echo "<result>NONE</result>"
			fi
		else
			echo "<result>Not installed</result>"
		fi
	fi
}
## Script
####################################################################################################
BackupPercent

