#!/bin/sh
# newscript07.03.12 14:42.sh
#
#
# Created by andrewws on 07/03/12.

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


## Functions
####################################################################################################
# Function 1

## Script
####################################################################################################
# Script Action 1

$CocoaDialog standard-inputbox --title "Input Box" --informative-text "Please Enter Something:" > $logFile
userinput=`cat $logFile | sed -n 2p`
userChoice=`cat $logFile | sed -n 1p`
echo "UserInput: $userinput"
echo "userChoice: $userChoice"
rm -f $logFile
