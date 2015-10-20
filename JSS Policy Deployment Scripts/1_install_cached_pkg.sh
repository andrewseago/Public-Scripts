#!/bin/sh
# 1_install_cached_pkg.sh
#
#
# Created by andrewws on 06/25/14.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
# Variables used for logging
logFile="/Library/Logs/gInstall/casperpush_install.log"
# Variables used by this script
InstallerExitCode=""
# Variables defined in Casper Admin
if [ "$4" != "" ]; then
	PathToPackages="$4"
else
	echo "PathToPackages not set"
	exit 0
fi
if [ "$5" == "" ] && [ "$6" == "" ] && [ "$7" == "" ] && [ "$8" == "" ] && [ "$9" == "" ]; then
	echo "PackageName variables not set"
	exit 0
else
	PackageName1="$5"
	PackageName2="$6"
	PackageName3="$7"
	PackageName4="$8"
	PackageName5="$9"
fi

## Functions
####################################################################################################
## LOGGING FUNCTION
log () {
	echo "---------------------------------------------------------------------------------------" >> $logFile
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S ") $1 >> $logFile
	echo "---------------------------------------------------------------------------------------" >> $logFile
}
## Install Package
function InstallPackage () {
	PackageDirectory="$1"
	PackageName="$2"
	FullPath="$PackageDirectory/$PackageName"
	InstallerExitCode=""
	if [ ! -e "$FullPath" ]; then
		log "$FullPath not found"
		InstallerExitCode="1"
	elif [ "$PackageDirectory" == "" ] || [ "$PackageName" == "" ]; then
		log "PackageDirectory or PackageName is blank"
	else
		log "Starting $FullPath install"
		installer -pkg "$FullPath" -target / >> $logFile
		InstallerExitCode="$?"
		if [ "$InstallerExitCode" != "0" ]; then
			log "ERROR: $FullPath install failed with error $InstallerExitCode"
		else
			log "SUCCESS: $FullPath install complete"
		fi
		log "Deleting $FullPath"
		SafetyPathCheck=`echo $FullPath | grep -e '.pkg$' -e '.mpkg$'` ## Ensures path is a pkg or mpkg and not something scary like /
		if [ "$SafetyPathCheck" != "" ]; then
			rm -Rf "$FullPath"
		else
			log "$FullPath did not pass the SafetyPathCheck and was not deleted"
		fi
	fi
}

## Script
####################################################################################################
if [ "$PackageName1" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName1"
fi
if [ "$PackageName2" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName2"
fi
if [ "$PackageName3" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName3"
fi
if [ "$PackageName4" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName4"
fi
if [ "$PackageName5" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName5"
fi
if [ "$PackageName6" != "" ]; then
	InstallPackage "$PathToPackages" "$PackageName6"
fi
log "Installation of all listed Packages Complete"
exit 0
