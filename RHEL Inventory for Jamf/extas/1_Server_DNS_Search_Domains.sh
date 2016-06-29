#!/bin/sh
# 1_Server_DNS_Search_Domains
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
extaID=18
extaName="Server - DNS Search Domains"
hostname=`hostname`
computerXmlPath="$1"
extaValue=`awk '/search /' /etc/resolv.conf | sed 's/search //'`
## Script
####################################################################################################
xmlstarlet ed --inplace -u "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" -v "${extaValue}" "$computerXmlPath"
exitCode="$?"
if [ "$exitCode" != '0' ]; then
        echo "ExitCode $exitCode while attempting to update $computerXmlPath with Exta: $extaName ID: ${extaID} with ${extaValue[@]}"
        exit 1
else
    	valueCheck=`xmlstarlet sel -t -c "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" "$computerXmlPath"`
        if [ "$valueCheck" == "<value>${extaValue}</value>" ]; then
                echo "$extaName updated"
		exit 0
	else
		echo "$extaName unable to be updated"
		exit 1
	fi
fi
