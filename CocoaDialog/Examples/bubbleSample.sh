#!/bin/sh
# bubbleSample.sh
# 
#
# Created by andrewws on 07/03/12.
# 
# Description: Sample Bubble Dialog
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
# Variables used for logging
logFile=/private/var/tmp/cocoaDialog.log

# Variables used by this script
CocoaDialog="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"
# Variables used by Casper

# Variables defined in Casper Admin

## Script
#################################################################################################### 
# Script Action 1

bubble1=`$CocoaDialog bubble --title "Installing Software Updates" --text "Safari 5.1.4" --icon-file "/System/Library/CoreServices/Software Update.app/Contents/Resources/SoftwareUpdate.icns"`
wait

echo "$bubble1"


echo "bubbleDone"