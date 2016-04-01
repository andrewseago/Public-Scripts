#!/bin/sh
#	CP - GUID Status
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
## Functions
####################################################################################################
function GUID_Status () {
	if [ "$CP_AdminUsername" == "" ] || [ "$CP_AdminPassword" == "" ];then
		echo "<result>Please ensure all variables are set in the extension attribute script.</result>"
	else
		if [ -f /Library/Application\ Support/CrashPlan/.identity ];then
			GUID=`/bin/cat /Library/Application\ Support/CrashPlan/.identity | grep guid | sed s/guid\=//g`
			GUIDStatus=`/usr/bin/curl -s -u ${CP_AdminUsername}:${CP_AdminPassword} -k "$CP_URL/api/Computer/${GUID}?idType=guid" | python -m json.tool | grep status | awk '{ print $2 }' | awk -F, '{ print $1 }' | sed 's/"//g'`
	    	if [ "$GUIDStatus" != "" ]; then
				echo "<result>$GUIDStatus</result>"
			else
				GUIDStatus=`/usr/bin/curl -s -u ${CP_AdminUsername}:${CP_AdminPassword} -k "$CP_URL/api/Computer/${GUID}?idType=guid"`
				GUIDStatusActive=`echo $GUIDStatus | grep '"COMPUTER","status":"Active"'`
				GUIDStatusDeactivated=`echo $GUIDStatus | grep '"COMPUTER","status":"Deactivated"'`
				if [ "$GUIDStatusActive" != "" ]; then
					echo "<result>Active</result>"
 				elif [ "$GUIDStatusDeactivated" != "" ]; then
					echo "<result>Deactivated</result>"
				else
					echo "<result>Orphan</result>"
				fi
			fi
		else
			echo "<result>Not installed</result>"
		fi
	fi
}

## Script
####################################################################################################
GUID_Status

