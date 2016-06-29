#!/bin/bash

CD="/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog"

rv=`$CD msgbox --no-newline \
	--title "Mac Updates Avalible" \
    --text "Updates are awaiting installation" \
    --informative-text "Your Mac has one or more updates wating to be installed. These updates will require a reboot. Once you have proceeded you will be asked to setup a time to install.

For more information press the 'More Info' button" \
    --button1 "Proceed" --button2 "More Info" --button3 "Cancel" \
	--icon sync --icon-size 128 --timeout 30 --debug --no-newline --string-output`
if [ "$rv" == "1" ]; then
    echo "User likes Macs"
elif [ "$rv" == "2" ]; then
    echo "User likes Linux"
elif [ "$rv" == "3" ]; then
    echo "User doesn't care"
fi
