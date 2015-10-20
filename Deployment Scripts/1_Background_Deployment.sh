#!/bin/sh
# 1_Background_Deployment.sh
#
#
# Created by andrewws on 06/25/14.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
# Variables defined in Casper Admin
EventTrigger="$4"
jamf_binary=`which jamf`
PolicyRunning=`ps -ax | grep -e "$jamf_binary policy -event $EventTrigger" | grep -v "grep"`
## Script
####################################################################################################
if [ "$PolicyRunning" != "" ]; then
	echo "A policy with the event trigger $EventTrigger is already running"
	echo "Ending Policy"
	exit 0
else
	echo "Starting policy with the event trigger $EventTrigger"
$jamf_binary policy -event "$EventTrigger" &
	echo "Ending Policy"
fi
