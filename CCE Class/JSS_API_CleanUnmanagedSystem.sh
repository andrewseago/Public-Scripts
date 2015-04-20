#!/bin/sh
# JSS_API_CleanUnmanagedSystem.sh
# 
#
# Created by andrewws on 04/16/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
api_user="ladmin"
api_password="jamf1234"
jssurl="https://jss.seagonet.net:8443"
StaticFilesToRemove='/var/companyHiddenFolder
/var/logs/jamf.log
/Library/CompanyPath
/Library/Fonts/Microsoft
/Applications/CrashPlan.app
/Library/LaunchDaemons/com.companyname.*
/Library/LaunchDaemons/com.department.*
/Library/LaunchAgents/com.companyname.*
/Library/LaunchAgents/com.department.*
/Library/Keychains/*'
StaticFilesToRemoveFile="/tmp/StaticFilesToRemoveFile.txt"
echo "$StaticFilesToRemove" > "$StaticFilesToRemoveFile"
ApplicationsToRemoveFile="/tmp/ApplicationsToRemove.txt"
UUID=`system_profiler SPHardwareDataType | awk '/Hardware UUID:/{print$3}'`
BadminWon='<?xml version="1.0" encoding="UTF-8"?>
<computer>
  <extension_attributes>
    <extension_attribute>
      <id>1</id>
      <name>Management Status</name>
      <type>String</type>
      <value>Badmin Won</value>
    </extension_attribute>
  </extension_attributes>
</computer>'
Managed='<?xml version="1.0" encoding="UTF-8"?>
<computer>
  <extension_attributes>
    <extension_attribute>
      <id>1</id>
      <name>Management Status</name>
      <type>String</type>
      <value>Managed</value>
    </extension_attribute>
  </extension_attributes>
</computer>'
statusXml="/tmp/status.xml"
jq_url="$url/required/jq.pkg"
## Functions
#################################################################################################### 
function VerifyJQ () {
    which jq &>/dev/null
    if [[ $? -ne 0 ]]; then
		curl -k -o /var/tmp/jq.pkg "$jq_url"
		installer -pkg /var/tmp/jq.pkg -target / 
    fi
}

function CheckEnrolled () {
	if [ -f /usr/sbin/jamf ]; then
		jssActive=`curl -s -I -k $jssurl/selfservice2 | grep '302 Found'`
		if [ "$jssActive" != "" ]; then
			rm -Rf /tmp/enrolled
			jamf policy -event enrollCheck
			if [ -f /tmp/enrolled ]; then
				echo "$Managed" > "$statusXml"
				ModifyJSSrecord
				exit 0
			else
				jamf policy -event enrollCheck
				if [ -f /tmp/enrolled ]; then
					echo "$Managed" > "$statusXml"
					ModifyJSSrecord
					exit 0
				else
					echo "$BadminWon" > "$statusXml"
					ModifyJSSrecord
				fi
			fi
		else
			# Not able to connect to JSS
			exit 0
		fi
	else
		echo "$BadminWon" > "$statusXml"
		ModifyJSSrecord
	fi			
}

function DeleteStaticFiles () {
	OLDIFS=$IFS
    IFS=$'\n'
	for path in $(cat $StaticFilesToRemoveFile); do
		rm -Rf "$path"
	done
	rm $StaticFilesToRemoveFile
	IFS=$OLDIFS
}
function DeleteApplications () {
	OLDIFS=$IFS
    IFS=$'\n'
	for path in $(cat $ApplicationsToRemoveFile); do
		rm -Rf "$path"
	done
	rm $ApplicationsToRemoveFile
	IFS=$OLDIFS
}
function GetLicencedSoftware () {
	OLDIFS=$IFS
    IFS=$'\n'
	for ID in $(curl -s -k -u $api_user:$api_password $jssurl/JSSResource/licensedsoftware -H "Accept: application/json" | jq .licensed_software[].id); do
		GetFilePaths $ID
	done
	IFS=$OLDIFS
}
function GetFilePaths () {
	ID=$1
	FilePath=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/licensedsoftware/id/$ID  -H "Accept: application/json" | jq .licensed_software.software_definitions[].name | sed 's/"//g'`
	if [ "$FilePath" == "" ]; then
		echo "/Applications/$FilePath" >> “$ApplicationsToRemoveFile"
	fi
}
function ModifyJSSrecord () {
	curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/udid/$UUID -X PUT -T "$statusXml"
}
function DeleteSelf () {
	/etc/JSS_API_CleanUnmanagedSystem.sh
	rm /System/Library/LaunchDaemons/com.apple.xyzutil.plist
}

function ScriptWorkflow () {
	VerifyJQ
	CheckEnrolled
	GetLicencedSoftware
	DeleteStaticFiles
	DeleteApplications
	DeleteSelf
}

## Script

#################################################################################################### 
ScriptWorkflow


