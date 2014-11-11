#!/bin/sh
# exta_icloud_status.sh
# 
# This extension attribute checks all users over UID 500 for their Keychain Sync and iCloud Drive / iCloud Document Sync status
# In Casper Results will look like this:
#	Username=User1 KeyChainStatus=true DocSyncStatus=true
#	Username=User2 KeyChainStatus=false DocSyncStatus=true
#
# Created by Andrew Seago on 11/11/14.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
#
#
## Variables
#################################################################################################### 
userList=(`dscl . -list /Users UniqueID | awk '$2 >= 500 { print $1; }' | grep -v -E '(messagebus|someuser|someohtheruser)'`)
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
ReconReport=''

## Script
#################################################################################################### 
for userAccount in ${userList[@]}; do
	UserDir=`/usr/bin/dscl . read /Users/$userAccount NFSHomeDirectory | cut -c 19-`
	if [ -e "$UserDir/Library/Preferences/MobileMeAccounts.plist" ]; then
		if [ "$osvers" == '10' ]; then
			KeyChainStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:8:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
			DocSyncStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:0:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
		elif [ "$osvers" == '9' ]; then
			KeyChainStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:7:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
			DocSyncStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:10:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
		elif [ "$osvers" == '8' ]; then
			KeyChainStatus='NA'
			DocSyncStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:7:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
		elif [ "$osvers" == '7' ]; then
			KeyChainStatus='NA'
			DocSyncStatus=`/usr/libexec/PlistBuddy -c "Print Accounts:0:Services:5:Enabled" "$UserDir/Library/Preferences/MobileMeAccounts.plist"`
		else
			KeyChainStatus='NA'
			DocSyncStatus='NA'
		fi
	else
		KeyChainStatus='NA'
		DocSyncStatus='NA'
	fi
	if [ "$KeyChainStatus" == "" ]; then
		KeyChainStatus='NA'
	elif [ "$DocSyncStatus" == "" ]; then
		DocSyncStatus='NA'
	fi
	if [ "$ReconReport" == "" ]; then
		ReconReport="Username=$userAccount KeyChainStatus=$KeyChainStatus DocSyncStatus=$DocSyncStatus"
	else
		ReconReport="$ReconReport
Username=$userAccount KeyChainStatus=$KeyChainStatus DocSyncStatus=$DocSyncStatus"
	fi
done
echo "<result>$ReconReport</result>"
exit 0

