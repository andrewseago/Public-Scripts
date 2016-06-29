#!/bin/sh
# 2_RHEL_CasperShare_Size.sh
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
extaID=29
extaName="CasperShare - Size"
computerXmlPath="$1"
if [ -d /data/CasperShare ]; then
	extaValue=`du -h --summarize /data/CasperShare/Packages | awk '{print$1}'`
	result="/data/CasperShare/Packages: $extaValue"
elif [ -d /NFS-SHARE/CasperShare ]; then
	extaValue=`du -h --summarize /NFS-SHARE/CasperShare/Packages: | awk '{print$1}'`
	result="/NFS-SHARE/CasperShare/Packages: $extaValue"
else
	result='NA'
fi
## Script
####################################################################################################
xmlstarlet ed --inplace -u "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" -v "$result" "$computerXmlPath"
exitCode="$?"
if [ "$exitCode" != '0' ]; then
	echo "ExitCode $exitCode while attempting to update $computerXmlPath with Exta: $extaName ID: ${extaID} with $result"
	exit 1
else
	valueCheck=`xmlstarlet sel -t -c "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" "$computerXmlPath"`
	if [ "$valueCheck" == "<value>${result}</value>" ]; then
		echo "$extaName updated"
		exit 0
	else
		echo "$extaName unable to be updated"
		exit 1
	fi
fi
