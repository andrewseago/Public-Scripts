#!/bin/bash
# CasperShare Package Count
# 
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

result=""
OLDIFS=$IFS
IFS=$'\n'
# read all file name into an array
fileArray=($(sharing -l | grep "CasperShare" | grep "path\:" | sed 's/path:		//'))
# restore it
IFS=$OLDIFS
# get length of an array
tLen=${#fileArray[@]}
for (( i=0; i<${tLen}; i++ )); do
    PackageNumber=`ls "${fileArray[$i]}/Packages/" | wc -w | awk '{print$1}'`
	if [ "$result" != "" ]; then
		result="$result
${fileArray[$i]}\: $PackageNumber"
	else
		result="${fileArray[$i]}\: $PackageNumber"
	fi
done
echo "<result>$result</result>"


#ea_display_name	CasperShare - Package Count
