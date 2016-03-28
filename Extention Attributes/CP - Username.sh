#!/bin/sh
#	CP - OrgName
#
# Updated Oct 19th 2015
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Script
####################################################################################################
if [ -f /Library/Application\ Support/CrashPlan/.identity ]; then
cru=$(grep username /Library/Application\ Support/CrashPlan/.identity | sed s/username=// | sed 's/\\//g')
if [ "$cru" == '' ]; then
	echo "<result>No Username</result>"
else
	echo "<result>$cru</result>"
fi
else
	echo "<result>Not installed</result>"
fi

