#!/bin/bash
# Repo_Sync_Policy.sh
#
#	This script is ment to be used in crontab or cron to control and retrieve updates.
#	This script makes sure that repo_sync is not already running.
# It then downloads all current updates using Reposada and removes any config data
#	as well as any deprecated updates that are not present in any branches
# This script is currently being ran on RHEL 6.6
# Updated 10/27/15
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
## Variables
####################################################################################################
logName="/data/Repo_Sync_Policy.log"
repo_sync="/data/SUS/reposado/code/repo_sync"
process_search_string="repo_sync"
## Functions
####################################################################################################
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logName
}
Check_Process_Running () {
	process_pid=`ps -ax 2>/dev/null | awk "/$process_search_string/" | awk 'NR>0{print $0}' | awk '!/awk/' | awk '{print$1}'`
	if [ "$process_pid" != "" ]; then
		log "$process_search_string found using PID $process_pid"
		log "Quiting Script"
		exit 0
	fi
}
RemoveConfigData () {
repoutil_ConfigUpdates=`python /data/SUS/reposado/code/repoutil --products | awk '/Config/{print$1}'	`
for update in ${repoutil_ConfigUpdates}; do
	log "Removing Config Data for $update"
	python /data/SUS/reposado/code/repoutil --remove-config-data "$update" >> $logName
done
}
InitializeScript () {
	Check_Process_Running
	log "Starting $process_search_string"
	`$repo_sync >> $logName`
	RemoveConfigData
	log "Purging all deprecated Updates that are not in any branches"
	/data/SUS/reposado/code/repoutil --purge-product all-deprecated >> $logName
	log "Completed $process_search_string"
}
## Script
####################################################################################################
InitializeScript
exit 0
