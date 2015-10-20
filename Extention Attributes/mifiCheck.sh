#!/bin/sh
# exta_Airport_MIFI.sh
#
#
# Created by andrewws on 03/25/14.
# Updated Oct 19th 2015
# Updated By Andrew Seago
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
# Variables used by this script
# Determine the OS version since the networksetup command differs on OS
OS=`sw_vers -buildVersion | /usr/bin/colrm 3`
extaPLIST="/var/gne/extas.plist"
extaCAT="Airport"
extaNAME="MiFi"
logName="/Library/Logs/gInstall/extas.log"
## Functions
####################################################################################################
function log () {
	echo $1
	echo $(date "+%Y-%m-%d %H\:%M:%S: ") $1 >> $logName
}
function wPlist () {
	# wPlist "$extaCAT:$extaNAME" "result" "$extaPLIST"
	Key=$1
	Value=$2
	PlistLocation=$3
	if [ "$Value" != "" ]; then
		log "Writing $Key = $Value to $PlistLocation"
		currentInfo=`/usr/libexec/PlistBuddy -c "Print :$Key" "$PlistLocation" 2>&1 /dev/null`
		if [ "$currentInfo" = "" ]; then
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		else
			/usr/libexec/PlistBuddy -c "Delete :$Key" "$PlistLocation"
			/usr/libexec/PlistBuddy -c "Add :$Key string $Value" "$PlistLocation"
		fi
	else
		log "$Key does not have a Value"
	fi
	chmod 644 "$PlistLocation"
}
## Script
####################################################################################################

# Attempt to read the current airport network for the current OS
if [ "$OS" == "9" ]; then
	SSID=`/usr/sbin/networksetup -getairportnetwork | sed 's/Current AirPort Network\: //g' | grep -v "GenenAir" | grep -v "guestwlan" | grep -v 'Campus;WLAN-001' | grep -v 'Campus;WLAN-003' > /private/var/tmp/.mifiCheck`
elif [ "$OS" == "10" ]; then
	SSID=`/usr/sbin/networksetup -getairportnetwork AirPort | sed 's/Current AirPort Network\: //g' | grep -v "GenenAir" | grep -v "guestwlan" | grep -v 'Campus;WLAN-001' | grep -v 'Campus;WLAN-003' > /private/var/tmp/.mifiCheck`
else
	device=`/usr/sbin/networksetup -listallhardwareports | grep -A 1 Wi-Fi | awk '/Device/{ print $2 }'`
	SSID=`/usr/sbin/networksetup -getairportnetwork $device | sed 's/Current Wi-Fi Network\: //g' | grep -v "GenenAir" | grep -v "guestwlan" | grep -v 'Campus;WLAN-001' | grep -v 'Campus;WLAN-003' > /private/var/tmp/.mifiCheck`
fi

# Ensure that AirPort was found
hasAirPort=`wc /private/var/tmp/.mifiCheck | awk '{print$1}' | grep 0`

if [ "$hasAirPort" = "" ]; then
	if [ "$OS" == "9" ] || [ "$OS" == "10" ]; then
		MiFiGateway=`networksetup -getinfo "AirPort" | grep "Router\:" | grep -v "IPv6" | awk '{print$2}'`
	else
		MiFiGateway=`networksetup -getinfo "Wi-Fi" | grep "Router\:" | grep -v "IPv6" | awk '{print$2}'`

	fi
	if [ "$MiFiGateway" != "none" ] || [ "$MiFiGateway" != "" ]; then
		SierraMifi=`curl -s http\://$MiFiGateway/index.html | grep -e "Sierra"`
		Mifi=`curl -s http\://$MiFiGateway/index.html | grep -e "MiFi"`
		VerizonMiFi=`curl -s http\://$MiFiGateway/index.html | grep -e "Verizon"`
		if [ "$VerizonMiFi" != "" ] || [ "$Mifi" != "" ] || [ "$SierraMifi" != "" ]; then
			MiFiStatus="TRUE"
		else
			MiFiStatus="FALSE"
		fi
	fi
fi

wwan=`networksetup -listnetworkserviceorder | grep "wwan" | cut -d "," -f1 | sed 's/(Hardware Port\: //g'`
if [ "$wwan" != "" ]; then
	wwanGateway=`networksetup -getinfo "$wwan" | grep "Router\:" | grep -v "IPv6" | awk '{print$2}'`
	if [ "$wwanGateway" != "none" ] || [ "$wwanGateway" != "" ]; then
		if [ "$wwanGateway" != "none" ] || [ "$wwanGateway" != "" ]; then
			curl http\://$wwanGateway/index.html -L | grep -q "Sierra"
			if [ "$?" == "0" ]; then
				WWANStatus="TRUE"
			else
				curl http\://$wwanGateway/index.html -L | grep -q "MiFi"
				if [ "$?" == "0" ]; then
					WWANStatus="TRUE"
				else
					WWANStatus="FALSE"
				fi
			fi
		fi

	fi
fi

if [ "$WWANStatus" = "TRUE" ]; then
	wPlist "$extaCAT:$extaNAME" "WWAN" "$extaPLIST"
	echo "<result>WWAN</result>"
else
	if [ "$MiFiStatus" = "TRUE" ]; then
		wPlist "$extaCAT:$extaNAME" "MiFi" "$extaPLIST"
		echo "<result>MiFi</result>"
	else
		wPlist "$extaCAT:$extaNAME" "NONE" "$extaPLIST"
		echo "<result>NONE</result>"
	fi
fi

exit 0
