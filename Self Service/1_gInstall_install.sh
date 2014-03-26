#!/bin/sh
#	1_gInstall_install.sh
#
# Manual URL: https://docs.google.com/a/gene.com/document/d/15Kar7Nc2_Qt5Q1KWpxsL5UNMGHu3aQrabH6zoD7dueg/edit
#
# Created by andrewws on 10/15/2012
# Copyright 2012 Genentech. All rights reserved.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

declare -x CocoaDialog="/private/var/gne/gInstall/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"
declare -x logFile="/Library/Logs/gInstall/gInstall_install.log"
declare -x mountPointDMG="/private/var/gne/gInstall/cache/.mountDMG"
declare -x installStatus=""
declare -x downloadStatus=""
## Icons
declare -x ProcessCompleteIcon="/var/gne/gInstall/icons/ProcessComplete.icns"
declare -x ProblemReporterIcon="/var/gne/gInstall/icons/ProblemReporter.icns"
declare -x PleaseWaitIcon="/var/gne/gInstall/icons/PleaseWait.icns"
declare -x InstallingPackagesIcon="/var/gne/gInstall/icons/InstallingPackages.icns"
declare -x CleaningUpIcon="/var/gne/gInstall/icons/CleaningUp.icns"
declare -x MtnLionIcon="/var/gne/gInstall/icons/MtnLion.icns"
declare -x SoftwareUpdateIcon="/var/gne/gInstall/icons/SoftwareUpdate.icns"
declare -x MacDNAIcon="/var/gne/gInstall/icons/MacDNA.icns"
declare -x gInstallIcon="/var/gne/gInstall/icons/gInstall.icns"
declare -x redXIcon="/var/gne/gInstall/icons/redX.icns"
declare -x redQuestionIcon="/var/gne/gInstall/icons/redQuestion.icns"
declare -x viruskillerIcon="/var/gne/gInstall/icons/viruskiller.icns"
declare -x globeIcon="/var/gne/gInstall/icons/globe.icns"
declare -x globeDownloadIcon="/var/gne/gInstall/icons/globeDownload.icns"
declare -x downloadMacIcon="/var/gne/gInstall/icons/downloadMac.icns"
declare -x ToolUtilitiesIcon="/var/gne/gInstall/icons/ToolUtilities.icns"
declare -x SyncIcon="/var/gne/gInstall/icons/Sync.icns"
declare -x ActivityMonitorIcon="/var/gne/gInstall/icons/ActivityMonitor.icns"
declare -x AirDropIcon="/var/gne/gInstall/icons/AirDrop.icns"
declare -x FileVaultIcon="/var/gne/gInstall/icons/FileVault.icns"
declare -x appdownloadIcon="/var/gne/gInstall/icons/app-download.icns"
declare -x PackagesIcon="/var/gne/gInstall/icons/Packages.icns"
### Policy set Variables
declare -x pathToDMG=""
declare -x dmgName=""
declare -x policyName=""
declare -x installType=""
declare -x preInstallTrigger=""
declare -x downloadTrigger=""
declare -x postTrigger=""
declare -x startDialog=""


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


# keyPackage is the name of the keyaccess package. MUST FOLLOW NAMING CONVENTION
# i.e. util_keyAccess_7.0.mpkg
if [ "$keyDMG" == "" ]; then   
    if [ "$7" == "" ]; then
    	keyDMG="NA"
    else
    	keyDMG="$7"
    fi
fi

if [ "$startDialog" = "" ]; then
	if [ "$8" = "" ]; then
		declare -x startDialog="NA"
	else
		declare -x startDialog="$8"
	fi
fi

if [ "$preInstallTrigger" = "" ]; then
	declare -x preInstallTrigger="$9"
fi

if [ "$downloadTrigger" = "" ]; then
	declare -x downloadTrigger="${10}"
fi

if [ "$postTrigger" = "" ]; then
	declare -x postTrigger="${11}"
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
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	$CocoaDialog progressbar --icon-file "$ActivityMonitorIcon" --float --title "$policyName" --text "Verifying Download......." --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate < /tmp/hpipe &
	exec 3<> /tmp/hpipe
	## Verify DMG package
	dmgVerify=`/usr/bin/hdiutil verify "$fullPathToDMG"`
	if [ $? == 0 ]; then
		log "Verify of $fullPathToDMG Complete"
		exec 3>&-
		wait
		rm -f /tmp/hpipe
	else
		installStatus="FAIL"
		log "There was an error verifying $fullPathToDMG Exit Code: $?"
		exec 3>&-
		wait
		rm -f /tmp/hpipe
		dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Verification of Download Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output --icon-height "92" --icon-width "92" --width "500" --height "132"`
		if [ "$dialog" = "Exit" ]; then
			cleanup
		else
			cleanup
		fi
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
				"$CocoaDialog" msgbox --no-newline --title "$policyName" --text "Install Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output --icon-height "92" --icon-width "92" --width "500" --height "132"
			fi
		fi
		if [ "$installStatus" = "Complete" ]; then
			"$CocoaDialog" msgbox --no-newline --title "$policyName" --text "$policyName Installation Complete" --informative-text "$policyName has been successfully installed. Please press Done to continue." --button1 "Done" --icon-file "$ProcessCompleteIcon" --float --string-output --icon-height "92" --icon-width "92"
			log "Exiting Install"
			exit 0
		else
			log "Exiting Install"
			exit 1
		fi
		

}

# Install using jamf on flat DMG dialog and check
function installDMG () {
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	$CocoaDialog progressbar --icon-file "$PackagesIcon" --float --title "$policyName" --text "Installing......." --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate < /tmp/hpipe &
	exec 3<> /tmp/hpipe
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
		exec 3>&-
		wait
		rm -f /tmp/hpipe
		log "$dmgName installed successfully"
		installStatus="Complete"
	else
		exec 3>&-
		wait
		rm -f /tmp/hpipe
		installStatus="FAIL"
		dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Install Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output --icon-height "92" --icon-width "92" --width "500" --height "132"`
		if [ "$dialog" = "Exit" ]; then
			cleanup
		else
			cleanup
		fi
	fi
}

## Install Mount DMG and install PKGs from within
function install_pkg () {
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	$CocoaDialog progressbar --icon-file "$gInstallIcon" --float --title "$policyName" --text "Starting Install....." --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate < /tmp/hpipe &
	exec 3<> /tmp/hpipe
	# Mount the DMG
	log "$installType Install"
	log "Mounting $dmgName..."
	rm "$mountPointDMG"
	/usr/bin/hdiutil mount -nobrowse -noautoopen -noverify -verbose "$fullPathToDMG" > "$mountPointDMG"
	if [ $? == 0 ]; then
		log "$dmgName mounted successfully"
	else
		exec 3>&-
		wait
		rm -f /tmp/hpipe
		installStatus="FAIL"
		log "There was an error mounting $dmgName Exit Code: $?"
		dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Install Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output --icon-height "92" --icon-width "92" --width "500" --height "132"`
		if [ "$dialog" = "Exit" ]; then
			cleanup
		else
			cleanup
		fi
	fi
	mountVolume=`cat "$mountPointDMG" | grep "Volumes" | cut -f 3-`
	mountDevice=`cat "$mountPointDMG" | grep "$mountVolume" | awk '{print $1}'`
	# Install the PKG wrapped inside the DMG
	log "Installing Packages from mount path $mountVolume..."
	exec 3>&-
	wait
	rm -f /tmp/hpipe
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
		rm -f /tmp/hpipe
		mkfifo /tmp/hpipe
		$CocoaDialog progressbar --icon-file "$PackagesIcon" --float --title "$policyName" --text "Installing ${fileArray[$i]}" --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate < /tmp/hpipe &
		exec 3<> /tmp/hpipe
		installer -package "$mountVolume/${fileArray[$i]}" -target / -verbose >> $logFile
		exec 3>&-
		wait
		rm -f /tmp/hpipe
		if [ $? == 0 ]; then
			log "${fileArray[$i]} installed successfully"
			installStatus="Complete"
		else
			installStatus="FAIL"
			dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Install Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output --icon-height "92" --icon-width "92" --width "500" --height "132"`
			if [ "$dialog" = "Exit" ]; then
				cleanup
			else
				cleanup
			fi
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



if [ "$startDialog" != "NA" ]; then
	dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Welcome to the $policyName" --informative-text "$startDialog" --button1 "Cancel" --button2 "Proceed" --icon-file "$gInstallIcon" --float --string-output `
	if [ "$dialog" = "Cancel" ]; then
		exit 0
	fi
fi


if [ "$preInstallTrigger" != "" ]; then
	log "Running PreInstall Trigger $preInstallTrigger"
	/usr/sbin/jamf policy -trigger "$preInstallTrigger" >> $logFile
	if [ $? == 0 ]; then
		log "$preInstallTrigger ran successfully"
	else
		installStatus="FAIL"
		dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Install Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output`
		if [ "$dialog" = "Exit" ]; then
			cleanup
		else
			cleanup
		fi
	fi
fi

if [ "$downloadTrigger" != "" ]; then
{
	log "Running Download Trigger $downloadTrigger"
	/usr/sbin/jamf policy -trigger "$downloadTrigger" >> $logFile
	if [ $? == 0 ]; then
		log "Download Complete"
	else
		installStatus="FAIL"
		log "Download Failed"
		downloadStatus="FAIL"
	fi
}|$CocoaDialog progressbar --icon-file "$globeDownloadIcon" --float --title "$policyName" --text "Downloading Installer" --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate
	if [ "$downloadStatus" = "FAIL" ]; then
		dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Download Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output`
		if [ "$dialog" = "Exit" ]; then
			cleanup
		else
			cleanup
		fi
	fi
fi



if [ ! -f "$fullPathToDMG" ]; then
	log "$fullPathToDMG Does not exist on the system"
	installStatus="FAIL"
	dialog=`$CocoaDialog msgbox --no-newline --title "$policyName" --text "Download Failed" --informative-text "Please Quit gInstall and verify you have a stable connection to the internet before attempting to install again" --button1 "Exit" --icon-file "$redXIcon" --float --string-output`
	if [ "$dialog" = "Exit" ]; then
		cleanup
	else
		cleanup
	fi
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