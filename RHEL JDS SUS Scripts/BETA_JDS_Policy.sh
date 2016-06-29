#!/bin/bash
# JDS_Policy.sh
#	This script is ment to be used in crontab or cron to control the JDS jamfds binary
# in configurations where a Master DP is also the Root JDS and files are uploaded via SMB
# to the CapserShare/Packages and then the Root JDS is used for replication.
# Updated 10/26/15
# Updated By Andrew Seago
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
## Variables
####################################################################################################
logName="/data/JDS_Policy.log"
process_search_string="JDS_Policy.sh"
self_pid=$$
smbRWuser='jdsrdw'
PreviousNumberOfPackages=`cat /data/CasperSharePackageCount`
NumberOfPackages=`ls /data/CasperShare/Packages | wc -w`
smbSharePath='/data/CasperShare'
FileUploading=''
pidFile="/tmp/$process_search_string.pid"
## Functions
####################################################################################################
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logName
}
Check_Process_Running () {
	if [ -e "$pidFile" ]; then
		process_pid=`ps -ax 2>/dev/null | awk "/$process_search_string/" | awk '!/awk/' | awk 'NR>0{print$0}' | awk '{print$1}'`
		previousPID=`cat $pidFile`
		for pid in ${process_pid}; do
			if [ "$pid" == "$previousPID" ]; then
				log "$process_search_string found using PID $pid"
				log "Quiting Script"
				exit 0
			fi
		done
		echo "$self_pid" > "$pidFile"
	else
		echo "$self_pid" > "$pidFile"
	fi
}
CheckUpload() {
  smbRWuserActive=`smbstatus -U | grep "$smbRWuser"`
  if [ "$smbRWuserActive" != '' ]; then
    FilesInUse=`smbstatus --user="$smbRWuser" | grep 'RDONLY\|RDWR' | grep -vw "$smbSharePath   ."`
     if [ "$FilesInUse" != '' ]; then
       log "Files are being uploaded or used by $smbRWuser"
       log "Sleeping for 2 min"
       sleep 120
       log "Starting jamfds Inventory"
       /usr/local/sbin/jamfds inventory
       log "jamfds Inventory has completed"
       log "Setting FileUpload status to 1"
       FileUploading=1
       log "Waiting 30 Sec for JSS Cluster"
       sleep 30
       log "Restarting CheckUpload function"
       CheckUpload
     fi
  elif [ "$FileUploading" = '1' ] || [ "$PreviousNumberOfPackages" != "$NumberOfPackages" ]; then
    log "File was previously uploaded or Number of Packages has changed"
    log "Waiting 30 sec for JSS Cluster"
    sleep 30
    log "Starting jamfds Inventory"
    /usr/local/sbin/jamfds inventory
    log "jamfds Inventory has completed"
    log "Waiting 30 sec for JSS Cluster"
    sleep 30
    log "Setting FileUpload status to 0"
    FileUploading=0
  fi
}
inventory(){
  log "Starting File Inventory"
  # save and change IFS
  OLDIFS=$IFS
  IFS=$'\n'
  # read all file name into an array
  for file in $(ls -1 /data/CasperShare/Packages);  do
    fullPathTofile="/data/CasperShare/Packages/$file"
    ModTime=`stat "$fullPathTofile" | awk '/Modify: /' | sed 's/Modify: //'`
    if [ -e '/data/CasperShareInventory' ]; then
      PreviousModTime=`grep "#$file#" /data/CasperShareInventory | cut -d '#' -f3`
			if [ "${PreviousModTime}" == "" ]; then
				log "${file} not found in CasperShareInventory"
				echo "#${file}#${ModTime}" >> /data/CasperShareInventory
      elif [ "${ModTime}" != "${PreviousModTime}" ]; then
        log "$file modification date has changed"
        log "Clearing MD5 Hash for $file"
        rm -Rf "$fullPathTofile.*"
        sed -i -e  "s/#${file}#${PreviousModTime}/#${file}#${ModTime}/" /data/CasperShareInventory
        log "Starting jamfds Inventory"
        CheckUpload
        log "jamfds Inventory has completed"
      fi
    else
			log "Creating CasperShareInventory"
      log "Starting jamfds Inventory"
      CheckUpload
      log "jamfds Inventory has completed"
      echo "#${file}#${ModTime}" >> /data/CasperShareInventory
    fi
  done
  IFS=$OLDIFS
	log "Starting jamfds Inventory"
	CheckUpload
	log "jamfds Inventory has completed"
	log "Waiting 30 sec for JSS Cluster"
	sleep 120
}
InitializeScript () {
	Check_Process_Running
	log "Starting $process_search_string"
	inventory
	log "Starting jamfds Policy"
	/usr/local/sbin/jamfds policy
	log "jamfds Policy has completed"
	NumberOfPackages=`ls /data/CasperShare/Packages | wc -w`
	log "Writing new number of packages"
	echo "$NumberOfPackages" > /data/CasperSharePackageCount
	log "Setting file permissions"
	chmod -Rf 777 /data/CasperShare/Packages
	chown -Rf tomcat7:Sysops /data/CasperShare/Packages
	log "JDS Policy complete"
	log "Completed $process_search_string"
	rm -f "$pidFile"
}
## Script
####################################################################################################
InitializeScript
exit 0
