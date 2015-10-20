#!/bin/sh
# progressbar.sh
# 
#
# Created by andrewws on 10/26/2012.
# 
# Description: Progress bar exsample that gets its percentage by echoing out
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute


CocoaDialog="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

{   echo "5 We're now at 5%"; sleep .5
	sleep 1
	echo "20 We're now at 20%"; sleep .5
	sleep 2
	echo "30 We're now at 30%"; sleep .5
	sleep 3
	echo "40 We're now at 40%"; sleep .5
	echo "100 We're now at 100%"; sleep .5
} > >($CocoaDialog progressbar ‑‑float --title "My Program2")
