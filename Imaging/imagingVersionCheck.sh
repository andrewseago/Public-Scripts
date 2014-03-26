#!/bin/sh
# imagingVersionCheck.sh
# 
#
# Created by andrewws on 06/11/12.
#
# This script is to be used in all Casper Imaging configurations as a before script. 
# It checks the JSS api and ensures that Casper Imaging matches the version currently on the server 
#
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute


if [ -e "/Applications/Casper Imaging.app/Contents/Info.plist" ]; then
	imagingVersion=`defaults read /Applications/Casper\ Imaging.app/Contents/Info.plist | grep CFBundleGetInfoString | awk '{print$3}' | sed "s/.\{1\}$//"`
else
	imagingVersion=`defaults read /Casper\ Imaging.app/Contents/Info.plist | grep CFBundleGetInfoString | awk '{print$3}' | sed "s/.\{1\}$//"`
fi

jssURL=`defaults read ~/Library/Preferences/com.jamfsoftware.jss.plist | grep "url" | awk '{print$3}' | sed "s/.\{1\}$//"`
jssVersion=`curl -k "$jssURL" | grep "version" | sed -e 's,.*<meta name="version" content=\([^<]*\)>.*,\1,g'`

if [[ "$jssVersion" != "$imagingVersion" ]]; then
	if [ -e "/Applications/Casper Imaging.app/Contents/" ]; then
		/Applications/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/MacOS/jamfHelper -windowType "utility" -button1 "Quit" -title "ALERT" -heading "Casper Imaging Version Mismatch" -description "Your Casper Drive is out of date! Upgrade your driveebefore attempting to use Casper Imaging" -icon /Applications/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/Resources/CasperImaging.png
	else
		/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/MacOS/jamfHelper -windowType "utility" -button1 "Quit" -title "ALERT" -heading "Casper Imaging Version Mismatch" -description "Your Casper Drive is out of date! Upgrade your driveebefore attempting to use Casper Imaging" -icon /Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/Resources/CasperImaging.png
	fi
	killall "Casper Imaging"
else
	if [ -e "/Applications/Casper Imaging.app/Contents/" ]; then
		/Applications/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/MacOS/jamfHelper -windowType "utility" -button1 "Quit" -title "ALERT" -heading "Casper Imaging Version Mismatch" -description "Your Casper Drive is up to date! Upgrade your drivee before attempting to use Casper Imaging" -icon /Applications/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/Resources/CasperImaging.png
	else
		/Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/MacOS/jamfHelper -windowType "utility" -button1 "Quit" -title "ALERT" -heading "Casper Imaging Version Mismatch" -description "Your Casper Drive is up to date! Upgrade your drivee before attempting to use Casper Imaging" -icon /Casper\ Imaging.app/Contents/Support/jamfHelper.app/Contents/Resources/CasperImaging.png
	fi
fi
