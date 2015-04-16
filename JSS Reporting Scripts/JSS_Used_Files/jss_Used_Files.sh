#!/bin/bash
# jss_Used_Files.sh
#
# This script will parse through all Policies and Image Configurations in the JSS specified for all Packages and Scripts being used.
# It will then compare the used files to the ones currently in your JSS and provide two seperate reports for each used and un-used files.
#
# Note: The username given to the script must have JSS API read access to the following: policies  computerconfigurations packages scripts
#
# Created by andrewws on 01/12/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
jssUrl=''
username=''
password=''
output=''

## Functions
####################################################################################################

function VerifyVariables () {
	if [ "$jssUrl" == "" ]; then
		echo "What is the JSS URL? ex. https://jss.acme.com:8443"
		read jssUrl
	fi
	if [ "$username" == "" ]; then
		echo "What is the api username?"
		read username
	fi
	if [ "$password" == "" ]; then
		echo "what is the api username password?"
		read -s password
	fi
	if [[ ! -d "$output" ]] || [[ "$output" == "" ]]; then
		echo "What is the output directory?"
		read output
	fi
	rm -Rf "$output/JSS_Used_Files"
	outputPlist="$output/JSS_Used_Files/results.plist"
}

function VerifyJQ () {
	which jq &>/dev/null
	if [[ $? -ne 0 ]]; then
		echo "This script requires the jq binary to be installed."
		exit 1
	fi
}

function GetAPIid () {
	jssAPItable="$1"
	echo "Getting ID's for $jssAPItable"
	mkdir -p "$output/JSS_Used_Files/$jssAPItable"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/$jssAPItable" | xmllint --format - | grep '<id>' | sed 's/<id>//' | sed 's/<\/id>//' | awk '{print$1}' > "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml"
	if [ ! -f "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml" ]; then
		echo "ERROR $output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml not dowloaded"
		exit 1
	fi
	idCount=$(wc -l "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml" | awk '{print$1}')
	myCount=0
	for apiObject in $(cat "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml"); do
		#clear
		let myCount=myCount+1
		echo "Parsing $jssAPItable $myCount of $idCount"
		GetAPIobject "$jssAPItable" "$apiObject"
		packageIDS=$(jq '.[] | .package_configuration | .packages[] | .id' $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | sed 's/\"//g')
		if [ "$packageIDS" != "" ]; then
			echo "$packageIDS" >> "$output/JSS_Used_Files/packageIDS.txt"
		fi
		scriptIDS=$(jq '.[] | .scripts[] | .id' "$output"/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | sed 's/\"//g')
		if [ "$scriptIDS" != "" ]; then
			echo "$scriptIDS" >> "$output/JSS_Used_Files/scriptIDS.txt"
		fi
		if [ "$jssAPItable" == "computerconfigurations" ]; then
			jq '.[] | .scripts | .[] | .script_contents'  $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | grep '.dmg"' | awk '{print$2}' | sed 's/\"//g' >> "$output/JSS_Used_Files/Packages.txt"
			newCount=0
			for packageName in $(cat "$output/JSS_Used_Files/Packages.txt"); do
				let newCount=newCount+1
				wPlist "ImagingPackages:$newCount" "$packageName" "$outputPlist"
			done
		fi
	done
}
function GetScriptFilename () {
	OLDIFS=$IFS
	IFS=$'\n'
	for scriptID in $(cat "$output/JSS_Used_Files/scriptIDS.txt"); do
		if [ "$scriptID" != "" ]; then
			scriptFilename=$(curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/scripts/id/$scriptID" | grep -e "<name>" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g')
			wPlist "Scripts:$scriptID" "$scriptFilename" "$outputPlist"
		fi
	done
	IFS=$OLDIFS
	#rm "$output/JSS_Used_Files/scriptIDS.txt"
}
function GetPackageFilename () {
	OLDIFS=$IFS
	IFS=$'\n'
	for packageID in $(cat "$output/JSS_Used_Files/packageIDS.txt"); do
		if [ "$packageID" != "" ]; then
			packageFilename=$(curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/packages/id/$packageID" | grep -e "<filename>" | sed -e 's,.*<filename>\([^<]*\)</filename>.*,\1,g')
			wPlist "Packages:$packageID" "$packageFilename" "$outputPlist"
		fi
	done
	IFS=$OLDIFS
	#rm "$output/JSS_Used_Files/packageIDS.txt"
	#rm "$output/JSS_Used_Files/Packages.txt"
}

function GetAPIobject () {
	jssAPItable="$1"
	jssAPIobject="$2"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/$jssAPItable/id/$jssAPIobject"  -H "Accept: application/json" > "$output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml"
}

function PrintResult () {
	declare -i PackageCount=$(/usr/libexec/PlistBuddy -c "Print :Packages" "$outputPlist" | grep '=' | awk '{print$1}' | wc -l | awk '{print$1}')
	declare -i ImagingPkgCount=$(/usr/libexec/PlistBuddy -c "Print :ImagingPackages" "$outputPlist" | grep '=' | awk '{print$1}' | wc -l | awk '{print$1}')
	scriptCount=$(/usr/libexec/PlistBuddy -c "Print :Scripts" "$outputPlist" | grep '=' | awk '{print$1}' | wc -l | awk '{print$1}')
	unusedPKGsCount=$(/usr/libexec/PlistBuddy -c "Print :Unused_Packages" "$outputPlist" | grep '=' | awk '{print$1}' | wc -l | awk '{print$1}')
	unusedScriptsCount=$(/usr/libexec/PlistBuddy -c "Print :Unused_Scripts" "$outputPlist" | grep '=' | awk '{print$1}' | wc -l | awk '{print$1}')
	pkgCount=$(expr $PackageCount + $ImagingPkgCount)
	chmod -R 777 "$output/JSS_Used_Files"
	echo ""
	echo ""
	echo "Packages Used: $pkgCount"
	echo "Packages Not Used: $unusedPKGsCount"
	echo "Scripts Used: $scriptCount"
	echo "Scripts Not Used: $unusedScriptsCount"
	echo ""
	echo "Package Used report is $output/JSS_Used_Files/Packages.txt"
	echo "Packages Not Used $output/JSS_Used_Files/Unused_Packages.txt"
	echo "Script report is $output/JSS_Used_Files/Scripts.txt"
	echo "Scripts Not Used report is $output/JSS_Used_Files/Unused_Scripts.txt"
}
function ScriptCleanup () {
	echo "Checking for unused Scripts"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/scripts" -H "Accept: application/json" > "$output/JSS_Used_Files/scripts.xml"
	OLDIFS=$IFS
	IFS=$'\n'
	for scriptID in $(jq '.scripts[] | .id' "$output/JSS_Used_Files/scripts.xml"); do
		scriptExist=$(/usr/libexec/PlistBuddy -c "Print :Scripts" $outputPlist | grep -e "$scriptID" | awk '{print$1}')
		if [ "$scriptExist" !=  "$scriptID" ]; then
			scriptFilename=$(curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/scripts/id/$scriptID" | grep -e "<name>" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g')
			wPlist "Unused_Scripts:$scriptID" "$scriptFilename" "$outputPlist"
		fi
	done
	IFS=$OLDIFS
}

function PackagesCleanup () {
	echo "Checking for unused Packages"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/packages" -H "Accept: application/json" > "$output/JSS_Used_Files/packages.xml"
	OLDIFS=$IFS
	IFS=$'\n'
	for packageID in $(jq '.packages[] | .id' "$output/JSS_Used_Files/packages.xml"); do
		PackageExist=$(/usr/libexec/PlistBuddy -c "Print :Packages" $outputPlist | grep "$packageID" | awk '{print$1}')
		if [ "$PackageExist" !=  "$packageID" ]; then
			packageFilename=$(curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/packages/id/$packageID" | grep -e "<filename>" | sed -e 's,.*<filename>\([^<]*\)</filename>.*,\1,g')
			wPlist "Unused_Packages:$packageID" "$packageFilename" "$outputPlist"
		fi
	done
	IFS=$OLDIFS
}

function wPlist () {
	Key=$1
	Value=$2
	PlistLocation=$3
	if [ "$Value" != "" ]; then
		currentInfo=$(/usr/libexec/PlistBuddy -c "Print :$Key" "$PlistLocation")
		if [ "$currentInfo" = "" ]; then
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		else
			/usr/libexec/PlistBuddy -c "Delete :$Key" "$PlistLocation"
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		fi
	fi
	chmod 777 "$PlistLocation"
}

## Script
####################################################################################################
VerifyJQ
VerifyVariables
GetAPIid policies
GetAPIid computerconfigurations
GetPackageFilename
GetScriptFilename
ScriptCleanup
PackagesCleanup
PrintResult

exit 0