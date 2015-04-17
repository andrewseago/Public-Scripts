#!/bin/sh
# Check4NoSite.sh
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
ComputersNoSite="/tmp/ComputersNoSite.txt"
SiteXML='<?xml version="1.0" encoding="UTF-8"?>
<computer>
  <general>
    <site>
      <id>14</id>
      <name>No Site Listed</name>
    </site>
  </general>
</computer>'

## Functions
#################################################################################################### 
function VerifyJQ () {
    which jq &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Please install jq from http://stedolan.github.io/jq/"
        exit 1
    fi
}
function GetComputerID () {
	OLDIFS=$IFS
    IFS=$'\n'
	for ID in $(curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers -H "Accept: application/json" | jq .computers[].id); do
		CheckSite $ID
	done
	IFS=$OLDIFS
}
function CheckSite () {
	ID=$1
	siteName=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID/subset/General  -H "Accept: application/json" | jq .computer.general.site.name | grep -v "None"`
	if [ "$siteName" == "" ]; then
		echo "$ID" >> "$ComputersNoSite"
	fi
}
function FixSiteName () {
	echo "$SiteXML" > /tmp/computer.xml
	OLDIFS=$IFS
    IFS=$'\n'
	for ID in $(cat $ComputersNoSite); do
		curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID -X PUT -T /tmp/computer.xml
	done
	IFS=$OLDIFS
}

function ScriptWorkflow () {
	VerifyJQ
	GetComputerID
	FixSiteName
}

## Script

#################################################################################################### 
ScriptWorkflow


