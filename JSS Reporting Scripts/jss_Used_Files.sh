#!/bin/sh
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
		read password
	fi
	if [[ ! -d "$output" ]] || [[ "$output" == "" ]]; then
		echo "What is the output directory?"
		read output
	fi
	rm -Rf "$output/JSS_Used_Files"
}

function GetAPIid () {
	jssAPItable="$1"
	echo "Getting ID's for $jssAPItable"
	mkdir -p "$output/JSS_Used_Files/$jssAPItable"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/$jssAPItable" | xmllint --format - | grep "<id>" | sed 's/<id>//' | sed 's/<\/id>//' | awk '{print$1}' > "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml"
	if [ ! -f "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml" ]; then
		echo "ERROR $output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml not dowloaded"
		exit 0
	fi
	idCount=`wc -l "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml" | awk '{print$1}'`
	OLDIFS=$IFS
	IFS=$'\n'
	myCount=0
	for apiObject in $(cat "$output/JSS_Used_Files/$jssAPItable/ID_$jssAPItable.xml"); do
		clear
		let myCount=myCount+1
		echo "Parsing $jssAPItable $myCount of $idCount"
		GetAPIobject "$jssAPItable" "$apiObject"
		if [ "$jssAPItable" == "computerconfigurations" ]; then
			packageName=`xmllint --xpath //packages $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | grep -e "filename" | sed -e 's,.*<filename>\([^<]*\)</filename>.*,\1,g'`
		else
			packageName=`xmllint --xpath //packages $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | grep -e "name" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g'`
		fi
		if [ "$packageName" != "" ]; then
			if [ -e "$output/JSS_Used_Files/Packages.txt" ]; then
				grep -r "$packageName" "$output/JSS_Used_Files/Packages.txt" > /dev/null 2>&1
				if [ "$?" == '1' ]; then
					echo  "$packageName" >> "$output/JSS_Used_Files/Packages.txt"
				fi
			else
				echo  "$packageName" >> "$output/JSS_Used_Files/Packages.txt"
			fi
		fi
		if [ "$jssAPItable" == "computerconfigurations" ]; then
			ScriptName=`xmllint --xpath //scripts $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | grep -e "filename" | sed -e 's,.*<filename>\([^<]*\)</filename>.*,\1,g'`
		else
			ScriptName=`xmllint --xpath //scripts $output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml | grep -e "name" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g'`
		fi
		if [ "$ScriptName" != "" ]; then
			if [ -e "$output/JSS_Used_Files/Scripts.txt" ]; then
				grep -r "$ScriptName" "$output/JSS_Used_Files/Scripts.txt" > /dev/null 2>&1
				if [ "$?" == '1' ]; then
					echo  "$ScriptName" >> "$output/JSS_Used_Files/Scripts.txt"
				fi
			else
				echo  "$ScriptName" >> "$output/JSS_Used_Files/Scripts.txt"
			fi
		fi
	done
	IFS=$OLDIFS
}

function GetAPIobject () {
	jssAPItable="$1"
	jssAPIobject="$2"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/$jssAPItable/id/$jssAPIobject" | xmllint --format - > "$output/JSS_Used_Files/$jssAPItable"/"$jssAPItable"_"$jssAPIobject.xml"
}

function SortOutput () {
	sort -d "$output/JSS_Used_Files/Scripts.txt" > "$output/JSS_Used_Files/Scripts_sort.txt"
	mv -f "$output/JSS_Used_Files/Scripts_sort.txt" "$output/JSS_Used_Files/Scripts.txt"
	sort -d "$output/JSS_Used_Files/Packages.txt" > "$output/JSS_Used_Files/Packages_sort.txt"
	mv -f "$output/JSS_Used_Files/Packages_sort.txt" "$output/JSS_Used_Files/Packages.txt"
}

function PrintResult () {
	pkgCount=`wc -l "$output/JSS_Used_Files/Packages.txt" | awk '{print$1}'`
	scriptCount=`wc -l "$output/JSS_Used_Files/Scripts.txt" | awk '{print$1}'`
	unusedPKGsCount=`wc -l "$output/JSS_Used_Files/Unused_Packages.txt" | awk '{print$1}'`
	unusedScriptsCount=`wc -l "$output/JSS_Used_Files/Unused_Scripts.txt" | awk '{print$1}'`
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
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/scripts" | xmllint --format - > "$output/JSS_Used_Files/scripts.xml"
	OLDIFS=$IFS
	IFS=$'\n'
	for scriptName in $(cat $output/JSS_Used_Files/scripts.xml | grep -e "name" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g'); do
		grep -r "$scriptName" "$output/JSS_Used_Files/Scripts.txt" > /dev/null 2>&1
		if [ "$?" == '1' ]; then
			echo  "$scriptName" >> "$output/JSS_Used_Files/Unused_Scripts.txt"
		fi
	done
	IFS=$OLDIFS
}
function PackagesCleanup () {
	echo "Checking for unused Packages"
	curl -k -s -u "$username":"$password" "$jssUrl/JSSResource/packages" | xmllint --format - > "$output/JSS_Used_Files/packages.xml"
	OLDIFS=$IFS
	IFS=$'\n'
	for packageName in $(cat $output/JSS_Used_Files/packages.xml | grep -e "name" | sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g'); do
		grep -r "$packageName" "$output/JSS_Used_Files/Packages.txt" > /dev/null 2>&1
		if [ "$?" == '1' ]; then
			echo  "$packageName" >> "$output/JSS_Used_Files/Unused_Packages.txt"
		fi
	done
	IFS=$OLDIFS
}

## Script
#################################################################################################### 
# Script Action 1
VerifyVariables
GetAPIid policies
GetAPIid computerconfigurations
SortOutput 
ScriptCleanup
PackagesCleanup

PrintResult