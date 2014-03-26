#!/bin/sh
# slider.sh
# 
#
# Created by andrewws on 10/26/2012.
# 
# Description: Sample Slider Dialog
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute


## Variables
#################################################################################################### 
# Variables used for logging
logFile=/private/var/log/newscript.log

# Variables used by this script

# Variables used by Casper

# Variables defined in Casper Admin


## Functions
#################################################################################################### 
# Function 1

## Script
#################################################################################################### 
# Script Action 1


/Applications/cocoaDialog.app/Contents/MacOS/cocoaDialog slider --title stuff --button1 stuff1 --button2 stuff2 --items stuff3 stuff4 --min 100 --max 1000 --icon download --slider-label Things --always-show-value --debug