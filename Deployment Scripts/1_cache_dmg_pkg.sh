#!/bin/sh
#    1_cache_dmg_pkg.sh
#
#	This script allows DMG wrapped PKGs to be downloaded and then copied to different locations on the system.
#	Depending on the CacheType specified it will either copy the entire DMG or mount the DMG and copy all PKGs from within.
#
# Created by andrewws on 02/25/2015
# set -x    # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
logFile="/Library/Logs/casper_push_cached_pkg.log"
mountPointDMG="/private/var/tmp/.mountDMG"
pathToDMG="/Library/Application Support/JAMF/Waiting Room/"
installStatus=""
downloadStatus=""
### Policy set Variables
# CacheType specifies if the DMG should be copied to DestinationPath or if it should be mounted and the contents copied to DestinationPath
# DMG = Copy the DMG, PKG = Mount the DMG and Copy its contents to DestinationPath
if [ "$CacheType" = "" ]; then
	CacheType="$4"
else
	log "ERROR NO CacheType!"
	exit 1
fi
# DestinationPath is destination of where the files should be placed
if [ "$5" != "" ]; then
	DestinationPath="$5"
	if [ ! -d "$DestinationPath/" ]; then
		mkdir -p "$DestinationPath/"
		chmod -Rf 777 "$DestinationPath"
	fi
else
	log "ERROR NO DestinationPath!"
	exit 1
fi
# dmgName is the full filename of the .dmg
if [ "$6" != "" ]; then
	dmgName0="$6"
else
	log "ERROR NO dmgName!"
	exit 1
fi
dmgName1="$7"
dmgName2="$8"
dmgName3="$9"
dmgName="${10}"
dmgName5="${11}"



## Functions
####################################################################################################
# LOGGING FUNCTION
log () {
	echo "---------------------------------------------------------------------------------------" >> $logFile
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile
	echo "---------------------------------------------------------------------------------------" >> $logFile
}

## Verify DMG package
function verify_DMG () {
	## Verify DMG package
	fullPathToDMG="$1"
	dmgName="$2"
	dmgVerify=`/usr/bin/hdiutil verify "$fullPathToDMG"`
	if [ $? == 0 ]; then
		log "Verify of $fullPathToDMG Complete"
	else
		installStatus="FAIL"
		log "There was an error verifying $fullPathToDMG Exit Code: $?"
		cleanup
	fi
}
function cleanup () {
		fullPathToDMG="$1"
		dmgName="$2"
		log "Removing $dmgName"
		/bin/rm "$fullPathToDMG" >> $logFile
		rm -Rf "$mountPointDMG"
}

## Copy DMG to DestinationPath
function copy_dmg () {
	fullPathToDMG="$1"
	dmgName="$2"
	cp -Rfv "$fullPathToDMG"  "$DestinationPath/" >> $logFile
	if [ $? == 0 ]; then
		log "$dmgName copied successfully"
		installStatus="Complete"
	else
		installStatus="FAIL"
		cleanup
	fi
}

##  Mount DMG and Copy PKGs from within to DestinationPath
function copy_pkg () {
	fullPathToDMG="$1"
	dmgName="$2"
	# Mount the DMG
	log "$CacheType Copy"
	log "Mounting $dmgName..."
	rm "$mountPointDMG"
	/usr/bin/hdiutil mount -nobrowse -noautoopen -noverify "$fullPathToDMG" > "$mountPointDMG"
	if [ $? == 0 ]; then
		log "$dmgName mounted successfully"
	else
		installStatus="FAIL"
		log "There was an error mounting $dmgName Exit Code: $?"
		cleanup
	fi
	mountVolume=`cat "$mountPointDMG" | grep "Volumes" | cut -f 3-`
	mountDevice=`cat "$mountPointDMG" | grep "$mountVolume" | awk '{print $1}'`
	# Copy PKGs  wrapped inside the DMG
	log "Copying Packages from mount path $mountVolume..."
	DIR="$mountVolume/"
	# failsafe - fall back to current directory
	[ "$DIR" == "" ] && DIR="."
	# save and change IFS
	OLDIFS=$IFS
	IFS=$'\n'
	# read all file name into an array
	fileArray=($(ls -1 $DIR | grep "pkg"))
	# restore it
	IFS=$OLDIFS
	# get length of an array
	tLen=${#fileArray[@]}
	for (( i=0; i<${tLen}; i++ ));
		do
		echo "${fileArray[$i]}"
		export mountVolume="$mountVolume"
		cp -Rfv "$mountVolume/${fileArray[$i]}"  "$DestinationPath/" >> $logFile
		if [ $? == 0 ]; then
			log "${fileArray[$i]} copied successfully"
			installStatus="Complete"
		else
			installStatus="FAIL"
			cleanup
		fi
	done
	# Unmount DMG
	if [[ -d "$mountVolume" ]]; then
		log "Unmounting disk $mountDevice..."
		hdiutil detach "$mountDevice" -force
	fi
}
function StartCacheMessage () {
	echo "#######################################################################################" >> $logFile
	echo "Starting $1 Cacheing" >> $logFile
	echo "#######################################################################################" >> $logFile
}
function CacheFlow () {
	fullPathToDMG="$1"
	dmgName="$2"
	log "Starting Copy of $dmgName"
	if [ "$CacheType" == "PKG" ] || [ "$CacheType" == "pkg" ]; then
		copy_pkg "$fullPathToDMG" "$dmgName"
	elif [ "$CacheType" == "DMG" ] || [ "$CacheType" == "dmg" ]; then
		copy_dmg "$fullPathToDMG" "$dmgName"
	else
		log "No valid CacheType specified"
		exit 1
	fi
}

## Script
####################################################################################################
if [ ! -d "/Library/Logs/gInstall" ]; then
	mkdir /Library/Logs/gInstall
	chmod -R 777 /Library/Logs/gInstall
fi
if [ "$dmgName0" != "" ]; then
	fullPathToDMG0="$pathToDMG$dmgName0"
	StartCacheMessage "$dmgName0"
	if [ ! -f "$fullPathToDMG0" ]; then
		log "$fullPathToDMG0 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG0"
	fi
	verify_DMG "$fullPathToDMG0" "$dmgName0"
	CacheFlow "$fullPathToDMG0" "$dmgName0"
	cleanup "$fullPathToDMG0" "$dmgName0"
else
	log "ERROR NO dmgName!"
	exit 1
fi
if [ "$dmgName1" != "" ]; then
	fullPathToDMG1="$pathToDMG$dmgName1"
	StartCacheMessage "$dmgName1"
	if [ ! -f "$fullPathToDMG1" ]; then
		log "$fullPathToDMG1 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG1"
	fi
	verify_DMG "$fullPathToDMG1" "$dmgName1"
	CacheFlow "$fullPathToDMG1" "$dmgName1"
	cleanup "$fullPathToDMG1" "$dmgName1"
fi
if [ "$dmgName2" != "" ]; then
	fullPathToDMG2="$pathToDMG$dmgName2"
	StartCacheMessage "$dmgName2"
	if [ ! -f "$fullPathToDMG2" ]; then
		log "$fullPathToDMG2 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG2"
	fi
	verify_DMG "$fullPathToDMG2" "$dmgName2"
	CacheFlow "$fullPathToDMG2" "$dmgName2"
	cleanup "$fullPathToDMG2" "$dmgName2"
fi
if [ "$dmgName3" != "" ]; then
	fullPathToDMG3="$pathToDMG$dmgName3"
	StartCacheMessage "$dmgName3"
	if [ ! -f "$fullPathToDMG3" ]; then
		log "$fullPathToDMG3 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG3"
	fi
	verify_DMG "$fullPathToDMG3" "$dmgName3"
	CacheFlow "$fullPathToDMG3" "$dmgName3"
	cleanup "$fullPathToDMG3" "$dmgName3"
fi
if [ "$dmgName4" != "" ]; then
	fullPathToDMG4="$pathToDMG$dmgName4"
	StartCacheMessage "$dmgName4"
	if [ ! -f "$fullPathToDMG4" ]; then
		log "$fullPathToDMG4 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG4"
	fi
	verify_DMG "$fullPathToDMG4" "$dmgName4"
	CacheFlow "$fullPathToDMG4" "$dmgName4"
	cleanup "$fullPathToDMG4" "$dmgName4"
fi
if [ "$dmgName5" != "" ]; then
	fullPathToDMG5="$pathToDMG$dmgName5"
	StartCacheMessage "$dmgName5"
	if [ ! -f "$fullPathToDMG5" ]; then
		log "$fullPathToDMG5 Does not exist on the system"
		installStatus="FAIL"
		cleanup
	else
		log "Found $fullPathToDMG5"
	fi
	verify_DMG "$fullPathToDMG5" "$dmgName5"
	CacheFlow "$fullPathToDMG5" "$dmgName5"
	cleanup "$fullPathToDMG5" "$dmgName5"
fi
