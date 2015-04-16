#!/bin/sh
# installFirefox.sh
# 
#	For use as an after script in Casper Imaging
#	Created in my CCE Class for a challenge
# Created by andrewws on 04/15/15.

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
targetVolume=$3
file_path="$targetVolume/tmp/firefox.dmg"
latestVersion=`curl -s http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/latest/mac/en-US/ | grep 'Firefox ' | sed -e 's,.*<a href="\([^<]*\)>.*,\1,g' | sed 's/"//'`
downloadUrl="http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/latest/mac/en-US/$latestVersion"
mountPointDMG="$targetVolume/private/var/tmp/.mountDMG"

## Functions
#################################################################################################### 
function DownloadFile () {
	curl -s "$downloadUrl" -X GET -o "$file_path"
}
function InstallApp () {
	rm $mountPointDMG
	/usr/bin/hdiutil mount -nobrowse -noautoopen -noverify "$file_path" > "$mountPointDMG"
	mountVolume=`cat "$mountPointDMG" | grep "Volumes" | cut -f 3-`
	mountDevice=`cat "$mountPointDMG" | grep "$mountVolume" | awk '{print $1}'`
	AppToMove=`ls $mountVolume | grep ".app"`
	cp "$mountVolume/$AppToMove" "$targetVolume/Applications/"
	hdiutil detach "$mountDevice" -force
	rm "$file_path"
}

## Script
#################################################################################################### 
DownloadFile
InstallApp


