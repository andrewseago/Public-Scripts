#!/bin/sh
#	casper_push_postinstall_check.sh
#	This is identical to the 1_ginstall_install.sh script however it does not have any dialog to users. 
#
# Created by andrewws on 05/14/2012

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute


declare -x logFile="/Library/Logs/gInstall/casperpush_install.log"
declare -x mountPointDMG="/private/var/tmp/.mountDMG"
declare -x installStatus=""
declare -x downloadStatus=""
## Icons

### Policy set Variables
declare -x pathToDMG=""
declare -x dmgName=""
declare -x policyName=""
declare -x installType=""



# dmgName is the full filename of the .dmg
if [ "$dmgName" = "" ]; then
	declare -x dmgName="$4"
fi
# pathToDMG checks to see where the DMG is located and sets the appropriate path
if [ -f "/Library/Application Support/JAMF/Waiting Room/$dmgName" ]; then
	declare -x pathToDMG="/Library/Application Support/JAMF/Waiting Room/"
else
	declare -x pathToDMG="/private/var/gne/gInstall/cache/"
fi
# fullPathToDMG is the full path to the DMG
declare -x fullPathToDMG="$pathToDMG$dmgName"
# policyName is the dialog title for the policy
if [ "$policyName" = "" ]; then
	declare -x policyName="$5"
fi
# InstallType examples: 
#	DMG (dmg file) 
#	fut (dmg with "Fill user templates") 
#	feu (dmg with "Fill existing users") 
#	feu,fut (dmg with both "Fill existing users" and "Fill user templates")
#	pkg (dmg with an installable pkg)
if [ "$installType" = "" ]; then
	declare -x installType="$6"
fi

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
		log "Removing $dmgName"
		/bin/rm "$fullPathToDMG" >> $logFile
		if [ "$postTrigger" != "" ] && [ "$installStatus" = "Complete" ]; then
			log "Running postTrigger Trigger $postTrigger"
			/usr/sbin/jamf policy -trigger "$postTrigger" >> $logFile
			if [ $? == 0 ]; then
				log "$postTrigger ran successfully"
			else
				installStatus="FAIL"
			fi
		fi
		if [ "$installStatus" = "Complete" ]; then
				log "Exiting Install"
			exit 0
		else
			log "Exiting Install"
			exit 1
		fi
		

}

# Install using jamf on flat DMG dialog and check
function installDMG () {
	if [ "$installType" == "DMG" ]; then
		log "$installType Install"
		/usr/sbin/jamf install -package "$dmgName" -path "$pathToDMG"  -target / -progress -verbose >> $logFile
	fi
	
	####	fut (dmg with "Fill user templates") Installer
	if [ "$installType" == "fut" ]; then
		log "$installType Install"
		/usr/sbin/jamf install -package "$dmgName" -path "$pathToDMG"  -target / -progress -verbose -fut >> $logFile
	fi
	####	feu (dmg with "Fill existing users") installer
	if [ "$installType" == "feu" ]; then
		log "$installType Install"
		/usr/sbin/jamf install -package "$dmgName" -path "$pathToDMG"  -target / -progress -verbose -feu >> $logFile
	fi
	####	feu,fut (dmg with both "Fill existing users" and "Fill user templates") installer
	if [ "$installType" == "feu,fut" ]; then
		log "$installType Install"
		/usr/sbin/jamf install -package "$dmgName" -path "$pathToDMG"  -target / -progress -verbose -feu -fut >> $logFile
	fi
	if [ $? == 0 ]; then

		log "$dmgName installed successfully"
		installStatus="Complete"
	else
		installStatus="FAIL"
	
		cleanup
	fi
}

## Install Mount DMG and install PKGs from within
function install_pkg () {
	# Mount the DMG
	log "$installType Install"
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
	# Install the PKG wrapped inside the DMG
	log "Installing Packages from mount path $mountVolume..."
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
		installer -package "$mountVolume/${fileArray[$i]}" -target / -verbose >> $logFile
		if [ $? == 0 ]; then
			log "${fileArray[$i]} installed successfully"
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

### Script
if [ ! -d "/Library/Logs/gInstall" ]; then
	mkdir /Library/Logs/gInstall
	chmod -R 777 /Library/Logs/gInstall
fi

echo "#######################################################################################" >> $logFile
echo "Starting $policyName" >> $logFile
echo "#######################################################################################" >> $logFile

if [ ! -f "$fullPathToDMG" ]; then
	log "$fullPathToDMG Does not exist on the system"
	installStatus="FAIL"
	cleanup
else
	log "Found $fullPathToDMG"
fi

verify_DMG

log "Starting Install of $dmgName"
if [ "$installType" == "pkg" ]; then
	install_pkg
else
	installDMG
fi

cleanup