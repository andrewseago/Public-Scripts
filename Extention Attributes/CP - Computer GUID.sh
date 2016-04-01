#!/bin/sh
#	CP - Computer GUID
#
# Updated 03/28/2016
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Script
####################################################################################################
if [ -f /Library/Application\ Support/CrashPlan/.identity ]; then
     GUID=`grep guid /Library/Application\ Support/CrashPlan/.identity | sed s/guid=//g`
     if [ "$GUID" == '' ]; then
          echo "<result>No GUID</result>"
     else
          echo "<result>$GUID</result>"
     fi

else
  echo "<result>Not Installed</result>"
fi
