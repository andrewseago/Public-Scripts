#!/bin/sh
# InstallPackagesToDisk.sh
# 
#
# Used to install multiple PKG containing DMGs and PKGs to a target drive based on what folders they are in
# Created by andrewws on 11/24/14.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
# Variables used for logging
logFile="~/Library/Logs/InstallPackagesToDisk.log"

# Variables used by this script
if [ "$1" == "" ]; then
	echo "Would you like to also install DMGs from a Directory? (Yes, No)"
	read answer
	if [ "$answer" == "Yes" ]; then
		echo "Please enter a DMG Directory:"
		read DMG_Directory
		if [ "$DMG_Directory" == "" ]; then 
			exit 1
		fi
	else
		echo "No DMGs will be installed"
	fi
else
	DMG_Directory="$1"
fi

if [ "$2" == "" ]; then
	echo "Would you like to also install PKGs from a Directory? (Yes, No)"
	read answer
	if [ "$answer" == "Yes" ]; then
		echo "Please enter a PKG Directory:"
		read PKG_Directory
		if [ "$PKG_Directory" == "" ]; then 
			exit 1
		fi
	else
		echo "No PKGs will be installed"
	fi
else
	PKG_Directory="$2"
fi

if [ "$3" == "" ]; then
		echo "Please enter a Target Drive Path: (ex /Volumes/Macintosh HD)"
		read TargetDisk
		if [ "$TargetDisk" == "" ]; then 
			exit 1
		fi
else
	TargetDisk="$3"
fi

mountPointDMG="/private/var/tmp/.mountDMG"
## Functions
#################################################################################################### 
## Install Packages function
install_DMG_Directory() {
	for dmgFile in `ls -1 "$DMG_Directory" | grep "dmg"`; do
		rm $mountPointDMG
		fullPathToDMG="$DMG_Directory/$dmgFile"
		/usr/bin/hdiutil mount -nobrowse -noautoopen -noverify "$fullPathToDMG" > "$mountPointDMG"
		if [ $? == 0 ]; then
			echo "$dmgFile mounted successfully"
		else
			installStatus="FAIL"
			echo "There was an error mounting $dmgFile Exit Code: $?"
		fi
		mountVolume=`cat "$mountPointDMG" | grep "Volumes" | cut -f 3-`
		mountDevice=`cat "$mountPointDMG" | grep "$mountVolume" | awk '{print $1}'`
		for pkgFile in `ls -1 "$mountVolume" | grep "pkg"`; do
			echo "installing package $pkgFile from dmg $dmgFile"
			installer -package "$mountVolume/$pkgFile" -target "$TargetDisk"
			if [ $? == 0 ]; then
				echo "$pkgFile installed successfully"
			else
				echo "$pkgFile installation failed.  Exit code: $?"
				echo "Attempting to install again with Verbose Logging"
				installer -package "$mountVolume/$pkgFile" -target "$TargetDisk" -verboseR
				if [ $? == 0 ]; then
					echo "$pkgFile installed successfully"
				else
					echo "$pkgFile installation failed.  Exit code: $?"
				fi
			fi	
		done	
		# Unmount DMG
		if [[ -d "$mountVolume" ]]; then
			echo "Unmounting disk $mountDevice..."
			hdiutil detach "$mountDevice" -force
		fi
	done
}

function install_PKG_Directory () {
	for pkgFile in `ls -1 "$PKG_Directory" | grep "pkg"`; do
		echo "installing package $pkgFile from dmg $dmgFile"
		installer -package "$PKG_Directory/$pkgFile" -target "$TargetDisk"
		if [ $? == 0 ]; then
			echo "$pkgFile installed successfully" 
		else
			echo "$pkgFile installation failed.  Exit code: $?"
			echo "Attempting to install again with Verbose Logging"
			installer -package "$PKG_Directory/$pkgFile" -target "$TargetDisk" -verboseR
			if [ $? == 0 ]; then
				echo "$pkgFile installed successfully"
			else
				echo "$pkgFile installation failed.  Exit code: $?"
			fi
		fi	
	done
}
## Script
#################################################################################################### 
if [ "$DMG_Directory" != "" ] && [ "$TargetDisk" != "" ]; then
	echo "Starting DMG Installations"
	install_DMG_Directory
else
	echo "Skipping DMG Installs"
fi
if [ "$PKG_Directory" != "" ] && [ "$TargetDisk" != "" ]; then
	echo "Starting PKG Installations"
	install_PKG_Directory
else
	echo "Skipping DMG Installs"
fi