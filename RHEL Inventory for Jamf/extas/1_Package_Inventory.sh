#!/bin/sh
# 1_Package_Inventory
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
hostname=`hostname`
computerXmlPath="$1"

## Script
####################################################################################################
for package in `rpm -qa`; do
	xmlstarlet ed --inplace --subnode /computer/software/installed_by_installer_swu --type elem -n package -v "$package" "$computerXmlPath"
done
