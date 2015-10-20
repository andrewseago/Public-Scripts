#!/bin/sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
reposadoPlist=`mdfind -name repo_sync | grep "/reposado/code/repo_sync" | sed 's/repo_sync/preferences.plist/g'`
if [ "$reposadoPlist" == "" ]; then
	if [ -f '/usr/local/bin/preferences.plist' ]; then
		reposadoPlist="/usr/local/bin/preferences.plist"
	fi
fi
if [ -f "$reposadoPlist" ]; then
	htmlPath=`defaults read "$reposadoPlist" UpdatesRootDir`
	if [ "$htmlPath" == "/data/SUS/html/" ]; then
		htmlPath="/data/SUS/html"
		echo "<result>$htmlPath</result>"
	else
		echo "<result>$htmlPath</result>"
	fi
else
	echo "<result>NA</result>"
fi


#ea_display_name	SUS - htmlPath
