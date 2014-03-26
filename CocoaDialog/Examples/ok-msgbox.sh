#!/bin/sh
# ok-msgbox.sh
# 
#
# Created by andrewws on 10/26/2012.
# 
# Description: OK msgbox
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute


CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

rv=`$CD ok-msgbox --text "We need to make sure you see this message" \
    --informative-text "(Yes, the message was to inform you about itself)" \
    --no-newline --float \
	--icon stop --icon-size 128 --height 190 --debug`
if [ "$rv" == "1" ]; then
    echo "User said OK"
elif [ "$rv" == "2" ]; then
    echo "Canceling"
    exit
fi
