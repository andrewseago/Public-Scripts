#!/bin/sh
# jss_user_setup.sh
# 
#
# Created by andrewws on 06/11/12.

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
#################################################################################################### 
# Variables used for logging
logFile="/private/var/log/jss_user_setup.log"
# Variables used by this script
jamf="/usr/sbin/jamf"
JSSurl=`defaults read /Library/Preferences/com.jamfsoftware.jamf "jss_url"`
checkJSSid=`syslog -C | grep -m1 "computer" | awk -F"<computer_id>" '{ print $2 }' | awk -F"</computer_id>" '{ print $1 }'`
MACaddress=`ifconfig | grep -m 1 ether | awk '{print $2}' | sed s/:/./g`
FirstBootRan="/Library/Genentech/.firstbootran"
privs="-DeleteFiles -ControlObserve -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings"
# Variables used by Casper
apiUser="apiUser"
apiPass="password"
managementUser="jss_localAdmin"
techUser="localAdminIT"
techPass="password"
rootPass="password"

# Variables defined in Casper Admin

techUserExists=`/usr/bin/dscl localhost -read /Local/Default/Users/"$techUser" 2>&1 | grep UserShell | awk '{print $2}'`




## Functions
#################################################################################################### 
# log function
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile	
}

# Reset Root and techUser Passwords
function resetPass () {
	if [ -f "$FirstBootRan" ]; then
		log "$techAdmin exists. Resetting Account"
		$jamf resetPassword -username "$techUser" -passhash "$techPassHashAPI" 2>&1 >> $logFile
		chown -R "$techUser":staff /var/"$techUser"
		log "Resetting Root Password"
		$jamf resetPassword -username 'root' -passhash "$rootPassHashAPI" 2>&1 >> $logFile
	else
		log "$techAdmin exists. Resetting Account"
		$jamf resetPassword -username "$techUser" -password "$techPass" 2>&1 >> $logFile
		chown -R "$techUser":staff /var/"$techUser"
		log "Resetting Root Password"
		$jamf resetPassword -username 'root' -password "$rootPass" 2>&1 >> $logFile
	fi
}

function createUsers () {
		if [ -f "$FirstBootRan" ]; then
			log "$techAdmin does not exist. Creating $techAdmin"
			$jamf createAccount -username "$techUser" -realname "$techUser" -passhash "$techPassHashAPI" -admin -hiddenUser 2>&1 >> $logFile
			chown -R "$techUser":staff /var/"$techUser"
			log "Resetting Root Password"
			$jamf resetPassword -username 'root' -passhash "$rootPassHashAPI" 2>&1 >> $logFile
		else
			log "$techAdmin does not exist. Creating $techAdmin"
			$jamf createAccount -username "$techUser" -realname "$techUser" -password "$techPass" -admin -hiddenUser 2>&1 >> $logFile
			chown -R "$techUser":staff /var/"$techUser"
			log "Resetting Root Password"
			$jamf resetPassword -username 'root' -password "$rootPass" 2>&1 >> $logFile
		fi
}

function managmentSSH_ARD () {
	systemsetup -setremotelogin on
	/usr/bin/dscl localhost -create /Local/Default/Groups/com.apple.access_ssh 2>&1 >> $logFile
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembership "$managementUser" 2>&1 >> $logFile
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh GroupMembers "$managementUser" 2>&1 >> $logFile
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh RealName 'Remote Login Group' 2>&1 >> $logFile
	/usr/bin/dscl localhost -append /Local/Default/Groups/com.apple.access_ssh PrimaryGroupID 104 2>&1 >> $logFile
	log "Enabling Apple Remote Desktop Agent..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate 2>&1 >> $logFile
	log "Setting Remote Management Privileges for User: $managementUser ..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs $privs -users $managementUser 2>&1 >> $logFile
}


## Script Logic
#################################################################################################### 

# Is the JSS avalible
jssAvalible
if [ "$url" = "FAIL" ]; then
	rootPassHashAPI="%c3%cc%f1%da%cb%d9%d9%8b%97%88%88%f7%91%de%c2%cf%c4"
	techPassHashAPI="%e7%ea%c9%f9%9e%de%e2%cf%fd%9b%c4%8b"
else
	techPassHashAPI="`curl -v -u "$apiUser":"$apiPass" "$JSSurl"JSSResource/peripherals/id/2/subset/General -X GET | sed -e 's,.*<field><name>genenadmin</name><value>\([^<]*\)</value>.*,\1,g'`"
	rootPassHashAPI="`curl -v -u "$apiUser":"$apiPass" "$JSSurl"JSSResource/peripherals/id/2/subset/General -X GET | sed -e 's,.*<field><name>root</name><value>\([^<]*\)</value>.*,\1,g'`"
fi



## Script
#################################################################################################### 
# Verify tech user Exist

if [ "$techUserExists" == "/bin/bash" ]; then
	resetPass
else
	createUsers
fi
	
	


