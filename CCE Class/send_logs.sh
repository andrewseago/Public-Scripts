#!/bin/sh
# send_logs.sh
# 
#	Copies specified files to a directory then compresses the directory and uploads it to a webdav share
#	Created in my CCE Class for a challenge
# Created by andrewws on 04/16/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
# Variables used for logging
logFile=/private/var/log/newscript.log
UUID=`system_profiler SPHardwareDataType | awk '/Hardware UUID:/{print$3}'`
webdav_url='http://jds.seagonet.net/logs'
webdav_user="webdavUser"
webdav_password="webdavPassword"
hostname=`hostname`
sn=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
date=`date "+%Y%m%d_%H.%M.%S"`
FileName="$hostname.$UUID.$date"
FilePath="/tmp/$FileName"


# Variables used by this script
if [ "$4" != "" ]; then
	log1_to_send="$4" # This is poplulated by Casper
else
	log1_to_send=""
fi

if [ "$5" != "" ]; then
	log2_to_send="$5" # This is poplulated by Casper
else
	log2_to_send=""
fi

if [ "$6" != "" ]; then
	log3_to_send="$6" # This is poplulated by Casper
else
	log3_to_send=""
fi

if [ "$7" != "" ]; then
	log4_to_send="$7" # This is poplulated by Casper
else
	log4_to_send=""
fi

if [ "$8" != "" ]; then
	log5_to_send="$8" # This is poplulated by Casper
else
	log5_to_send=""
fi

if [ "$9" != "" ]; then
	log6_to_send="$9" # This is poplulated by Casper
else
	log6_to_send=""
fi
if [ "${11}" != "" ]; then
	log7_to_send="${11}" # This is poplulated by Casper
else
	log7_to_send=""
fi
if [ "${10}" != "" ]; then
	log8_to_send="${10}" # This is poplulated by Casper
else
	log8_to_send=""
fi

## Functions
#################################################################################################### 
function CopyLogs () {
	mkdir -p "/tmp/$FileName"
	if [ -e "$log1_to_send" ]; then
		cp -R "$log1_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log2_to_send" ]; then
		cp -R "$log2_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log3_to_send" ]; then
		cp -R "$log3_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log4_to_send" ]; then
		cp -R "$log4_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log5_to_send" ]; then
		cp -R "$log5_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log6_to_send" ]; then
		cp -R "$log6_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log7_to_send" ]; then
		cp -R "$log7_to_send" "/tmp/$FileName/"
	fi
	if [ -e "$log8_to_send" ]; then
		cp -R "$log8_to_send" "/tmp/$FileName/"
	fi
}
function CompressLogs () {
	zip -r "/tmp/$FileName.zip" "/tmp/$FileName"
}
function SendLogs () {
	curl -k --digest --user ${webdav_user}:${webdav_password} "$webdav_url/$FileName.zip" -X PUT -T "$FilePath.zip"
}
function RemoveLogs () {
	#rm -Rf "/tmp/$FileName"
	rm -Rf "/tmp/$FileName.zip"
}

function ScriptWorkflow () {
	CopyLogs
	CompressLogs
	SendLogs
	RemoveLogs
}

## Script
#################################################################################################### 
ScriptWorkflow


