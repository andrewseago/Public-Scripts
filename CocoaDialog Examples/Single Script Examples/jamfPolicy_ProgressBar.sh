#!/bin/sh
# jamfPolicy_ProgressBar.sh
# 
#
# Created by andrewws on 10/26/2012.
# 
# Description: Function for calling a manual trigger that provides a progress bar with percentage of complete download.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables defined in Casper Admin
####################################################################################################
# Manual Trigger Name from the download policy you wish to leverage
declare -x manualTrigger="$4"
# Size of the Source DMG that will be downloaded
declare -x sourceSize="$5"
# Title of dialog window
declare -x Title="$6"
# Name of the DMG that that will be dowloaded
declare -x sourceName="$7"

declare -x downloadStatus=""
## Variables defined by the script
####################################################################################################
# Checks to see if the manual trigger is still active
declare -x psCheck=`ps -ae | grep "/usr/sbin/jamf policy -trigger $manualTrigger" | grep -v grep`
# Location of CocoaDialog
declare -x CocoaDialog="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"


## Function
#################################################################################################### 
function manualTriggerFunc () {
	/usr/sbin/jamf policy -trigger "$manualTrigger" -verbose > /private/var/tmp/."$manualTrigger"

}

function downloadProgress () {
	(
			/usr/sbin/jamf policy -trigger "$manualTrigger" &
			while [ `ps -ae | grep "/usr/sbin/jamf policy -trigger $manualTrigger" | grep -v grep | awk '{print$4}'` = "/usr/sbin/jamf" ]
			do
			  downloadProgress=`du -k  /Library/Application\ Support/JAMF/Downloads/"$sourceName" | awk '{print$1}'`
			  precent=`echo "$downloadProgress" "$sourceSize" | awk '{print$1/$2*100}' | cut -d "." -f1`
			  echo "$precent Download Progress $precent%"
			  sleep 1
			done 

	)|$CocoaDialog progressbar --icon-file "/var/gne/gInstall/icons/globeDownload.icns" --float --title "$Title" --text "Download in progress......." --icon-height "92" --icon-width "92" --width "500" --height "132"
	policyError=`cat /private/var/tmp/."$manualTrigger" | grep "Error" | grep -v "ASR Error"`
	if [ "$policyError" = "" ]; then
		downloadStatus="Sucsess"
		rm /private/var/tmp/."$manualTrigger"
	else
		downloadStatus="Fail"
		rm /private/var/tmp/."$manualTrigger"
	fi
}

downloadProgress


echo "$downloadStatus"

