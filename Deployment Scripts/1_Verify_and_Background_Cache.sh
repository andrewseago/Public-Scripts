#!/bin/sh
# 1_Verify_and_Background_Cache.sh
#
#
# Created by andrewws on 05/19/14.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
gInstallpreferencesDir="/var/gne/preferences"
gInstallpreferencesPLIST="$gInstallpreferencesDir/gInstall_Cache_Status"

if [ "$4" != "" ]; then
	DownloadTrigger="$4"
else
	echo "No DownloadTrigger provided"
	exit 0
fi
if [ "$5" != "" ]; then
	DMG_PKG_PATH="$5"
else
	echo "No DMG_PKG_PATH provided"
	exit 0
fi
if [ "$6" != "" ]; then
	MD4_FILE_PATH="$6"
else
	echo "No MD4_FILE_PATH provided"
	exit 0
fi
if [ "$7" != "" ]; then
	MD4_FILE_HASH="$7"
else
	echo "No MD4_FILE_HASH provided"
	exit 0
fi

CacheStatus=""
md4HashResult=""

if [ ! -d "$gInstallpreferencesDir" ]; then
	mkdir -p "$gInstallpreferencesDir"
fi
MD4_FILE_PATH_VERIFIED=`defaults read "$gInstallpreferencesPLIST" "$MD4_FILE_PATH"`
## Functions
####################################################################################################
function MD4hashCheck () {
	md4HashResult=""
	fileToCheck="$1"
	hashToMatch="$2"
	if [ "$fileToCheck" == "" ] || [ "$hashToMatch" == "" ]; then
		echo "Please provide the file path and Hash to compare"
	else
		fileMD4Hash=`openssl md4 $1 | awk '{print$2}'`
		if [[ "$fileMD4Hash" == "$hashToMatch" ]]; then
			md4HashResult="PASS"
			defaults write "$gInstallpreferencesPLIST" "$fileToCheck" "PASS"
		else
			defaults write "$gInstallpreferencesPLIST" "$fileToCheck" "FAIL"
			md4HashResult="HASHFAIL"
		fi
	fi
}

function ScriptProccessFlow () {
	CheckIfCached
	RunCachingPolicy
}

function CheckIfCached () {
	PolicyRunning=`ps -ax | grep -e "/usr/sbin/jamf policy -event $DownloadTrigger" | grep -v "grep"`
	if [ -e "$MD4_FILE_PATH" ] && [ "$MD4_FILE_PATH_VERIFIED" != "PASS" ]; then
		MD4hashCheck "$MD4_FILE_PATH" "$MD4_FILE_HASH"
		PolicyRunning=`ps -ax | grep -e "/usr/sbin/jamf policy -event $DownloadTrigger" | grep -v "grep"`
		if [ $md4HashResult = "HASHFAIL" ] && [ -e "$MD4_FILE_PATH" ] && [ "$PolicyRunning" == "" ]; then
			echo "$DMG_PKG_PATH Cache failed"
			echo "Removing $DMG_PKG_PATH Cache"
			rm -rf "$MD4_FILE_PATH"
			CacheStatus="FALSE"
		elif [ $md4HashResult = "HASHFAIL" ] && [ -e "$MD4_FILE_PATH" ] && [ "$PolicyRunning" != "" ]; then
			echo "$DownloadTrigger Policy Is running"
			exit 0
		elif [ -e "$MD4_FILE_PATH" ] && [ "$md4HashResult" == "PASS" ]; then
			echo "$DMG_PKG_PATH Cache Valid"
			CacheStatus="TRUE"
		fi
	elif [ ! -e "$MD4_FILE_PATH" ] && [ "$PolicyRunning" == "" ]; then
		echo "$DMG_PKG_PATH Cache not found"
		CacheStatus="FALSE"
	elif [ ! -e "$MD4_FILE_PATH" ] && [ "$PolicyRunning" != "" ]; then
		echo "$DownloadTrigger Policy Is running"
		exit 0
	elif [ -e "$MD4_FILE_PATH" ] && [ "$MD4_FILE_PATH_VERIFIED" == "PASS" ]; then
		echo "$DMG_PKG_PATH Cache Valid"
		CacheStatus="TRUE"
	fi
}

function RunCachingPolicy () {
	if [ "$CacheStatus" == "FALSE" ]; then
		echo "Starting $DMG_PKG_PATH Cache Download"
		/usr/sbin/jamf policy -event "$DownloadTrigger" &
	fi
}

## Script
####################################################################################################
ScriptProccessFlow
