#!/bin/bash

CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

rv=`$CD radio --title "When can updates install?" \
    --text "When can these install?" \
    --no-newline --float \
	--items "Now" "15 mins" "30 mins" "1 hr" "3 hrs"\
	--button1 "Proceed" --button2 "Cancel" --button3 "More Info"\
	--icon download --icon-size 128 --timeout 30 --debug --no-newline --string-output `
echo "$rv"
