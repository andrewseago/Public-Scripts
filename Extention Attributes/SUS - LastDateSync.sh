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
	if [ -f "$htmlPath/content/catalogs/index_prod.sucatalog" ]; then
		LastDateSync=`date -j -f "%s" "$(stat -f "%m" $htmlPath/content/catalogs/index_prod.sucatalog)" +"%Y/%m/%d %T"`
	else
		LastDateSync=`date -j -f "%s" "$(stat -f "%m" $htmlPath/content/catalogs/index.sucatalog)" +"%Y/%m/%d %T"`
	fi
	if [ "$LastDateSync" == "" ]; then
		echo "<result>NA</result>"
	else
		echo "<result>$LastDateSync</result>"
	fi
else
	echo "<result>NA</result>"
fi


#ea_display_name	SUS - LastDateSync
