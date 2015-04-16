#!/bin/sh
# Check4NoFV2.sh
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
ComputersFV2="/tmp/ComputersFV2.txt"

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
		CheckFV2status $ID
	done
	IFS=$OLDIFS
}
function CheckFV2status () {
	ID=$1
	fv2status=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID/subset/Hardware  -H "Accept: application/json" | jq '.computer.hardware.storage[].partition | select(.type=="boot")' | jq .filevault2_status`
	if [ "$fv2status" != "Encrypted" ]; then
		echo "$ID" >> "$ComputersFV2"
	fi
}
function GrabUserInfo () {
	mkdir -p /tmp/Users_WithoutFV2
	OLDIFS=$IFS
    IFS=$'\n'
	for ID in $(cat $ComputersFV2); do
		email_address=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID/subset/Location  -H "Accept: application/json" | jq .computer.location.email_address`
		real_name=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID/subset/Location  -H "Accept: application/json" | jq .computer.location.real_name`
		phone=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID/subset/Location  -H "Accept: application/json" | jq .computer.location.phone`
		ComputerName=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID  -H "Accept: application/json" | jq .computer.general.name`
		report_date=`curl -s -k -u $api_user:$api_password $jssurl/JSSResource/computers/id/$ID  -H "Accept: application/json" | jq .computer.general.report_date`
		echo "real_name: $real_name" > "/tmp/Users_WithoutFV2/$real_name.$ComputerName"
		echo "phone: $phone" >> "/tmp/Users_WithoutFV2/$real_name.$ComputerName"
		echo "email_address: $email_address" >> "/tmp/Users_WithoutFV2/$real_name.$ComputerName"
		echo "ComputerName: $ComputerName" >> "/tmp/Users_WithoutFV2/$real_name.$ComputerName"
		echo "last_report_date: $report_date" >> "/tmp/Users_WithoutFV2/$real_name.$ComputerName"
	done
	IFS=$OLDIFS
}

function ScriptWorkflow () {
	VerifyJQ
	GetComputerID
	GrabUserInfo
}

## Script

#################################################################################################### 
ScriptWorkflow


