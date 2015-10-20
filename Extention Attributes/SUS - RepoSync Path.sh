#!/bin/sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
repo_sync=`mdfind -name repo_sync | grep "/reposado/code/repo_sync"`
if [ "$repo_sync" == "" ]; then
	if [ -f '/usr/local/bin/repo_sync' ]; then
		repo_sync="/usr/local/bin/repo_sync"
	fi
fi
if [ "$repo_sync" == "" ]; then
    repo_sync=`mdfind -name repo_sync`
    if [ "$repo_sync" == "" ]; then
        echo "<result>NA</result>"
    else
        echo "<result>$repo_sync</result>"
    fi
else
    echo "<result>$repo_sync</result>"
fi


#ea_display_name	SUS - RepoSync Path
