#!/bin/bash
# PurgeCasperShare.sh
# 
#
# Created by andrewws on 02/03/15.
# Copyright 2015 Genentech. All rights reserved.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
# Variables used by this script
CasperShare=''
output=''
jssUrl=''
username=''
password=''
outputPlist=""

## Functions
#################################################################################################### 
function InitiateScript () {
	CheckIfjq
	VerifyVariables
	PurgePackages
	PurgeScripts
}

function VerifyVariables () {
	echo "This script will take the output of jss_Used_Files.sh and use it to clean our unused packages and Scripts.

Press Return to Continue"
	read Continue
	if [ "$CasperShare" == "" ]; then
		echo "What is the path to your mounted master CasperShare? example: /Volumes/CasperShare"
		read CasperShare
	fi
	if [ "$jssUrl" == "" ]; then
		echo "What is the JSS URL? ex. https://jss.acme.com:8443"
		read jssUrl
	fi
	if [ "$username" == "" ]; then
		echo "What is the api username?"
		read username
	fi
	if [ "$password" == "" ]; then
		echo "what is the api username password?"
		read -s password
	fi
	if [[ ! -d "$output" ]] || [[ "$output" == "" ]]; then
		echo "What is the JSS_Used_Files output directory? example: /Users/Shared/JSS_Used_Files"
		read output
	fi
	outputPlist="$output/results.plist"
}
function PurgePackages () {
	OLDIFS=$IFS
	IFS=$'\n'
	for package in $(/usr/libexec/PlistBuddy -c 'Print :Unused_Packages' "$outputPlist" | grep '='); do
		packageID=`echo $package | cut -d '=' -f1 | awk '{print$1}'`
		packageName=`echo $package | cut -d '=' -f2 | sed 's/ //'`
		echo "Removing $packageName from the JSS"
		#curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/packages/id/$packageID" -X DELETE > /dev/null 2>&1
		if [ -e "$CasperShare/Packages/$packageName" ]; then
			echo "Removing $packageName from $CasperShare"
			#rm -Rf "$CasperShare/Packages/$packageName"
		else
			echo "$packageName Was Not Found in CasperShare"
		fi
	done
	IFS=$OLDIFS
}
function PurgeScripts () {
	OLDIFS=$IFS
	IFS=$'\n'
	for script in $(/usr/libexec/PlistBuddy -c 'Print :Unused_Scripts' "$outputPlist" | grep '='); do
		scriptID=`echo $script | cut -d '=' -f1 | awk '{print$1}'`
		scriptName=`echo $script | cut -d '=' -f2 | sed 's/ //'`
		echo "Removing $scriptName from the JSS"
		#curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/scripts/id/$scriptID" -X DELETE > /dev/null 2>&1
	done
	IFS=$OLDIFS	
}
function CheckIfjq () {
	if [ ! -e /usr/sbin/jq ]; then
		echo "Please install jq from http://stedolan.github.io/jq/"
		exit 0
	fi
}
	
## Script
#################################################################################################### 
InitiateScript
exit 0