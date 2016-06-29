#!/bin/sh
# 2_RHEL_Sudoers.sh
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
extaID=39
extaName="RHEL - Sudoers"
hostname=`hostname`
computerXmlPath="$1"
extaValue=`cat /etc/sudoers`
## Script
####################################################################################################
xmlstarlet ed --inplace -u "/computer/extension_attributes/extension_attribute[id=${extaID}]/value" -v "$extaValue" "$computerXmlPath"
