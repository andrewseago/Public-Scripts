#!/bin/sh
# 2_RHEL_UserCheck.sh
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
extaID=40
extaName="RHEL - User Check"
hostname=`hostname`
computerXmlPath="$1"
users=(andrewws simmonsv)
groups=(984 2281 2357 1950)

## Script
####################################################################################################
rm -f /tmp/tmpuserdump
for username in ${users[@]}; do
	getent passwd $username >> /tmp/tmpuserdump
	id $username >> /tmp/tmpuserdump
done
for groupname in ${groups[@]}; do
	getent group $groupname >> /tmp/tmpuserdump
done
extaValue=`cat /tmp/tmpuserdump`
xmlstarlet ed --inplace -u "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" -v "$extaValue" "$computerXmlPath"
