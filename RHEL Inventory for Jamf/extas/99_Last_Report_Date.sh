#!/bin/sh
# 2_Last_Report_Date.sh
#
#
# Created by andrewws on 04/05/16.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
# Variables used by this script
rootPath="/var/AutoMagic/git_repos/rhel_6_exta"
extaName="Last_Report_Date"
hostname=`hostname`
computerXmlPath="$1"
extaValue=`date "+%Y-%m-%d %H:%M:%S"`
## Script
####################################################################################################
xmlstarlet ed --inplace -u "/computer/general/report_date" -v "${extaValue}" "$computerXmlPath"
xmlstarlet ed --inplace -u "/computer/general/last_contact_time" -v "${extaValue}" "$computerXmlPath"
exitCode="$?"
if [ "$exitCode" != '0' ]; then
	echo "ExitCode $exitCode while attempting to update $computerXmlPath with ${extaValue}"
	exit 1
else
	valueCheck=`xmlstarlet sel -t -c "/computer/general/report_date" "$computerXmlPath"`
	if [ "$valueCheck" == "<report_date>${extaValue}</report_date>" ]; then
		echo "$extaName updated"
		exit 0
	else
		echo "$extaName unable to be updated"
		exit 1
	fi
fi
