#!/bin/sh
# set -x
# Determine the OS version since the networksetup command differs on OS
OS=`/usr/bin/sw_vers -productVersion | /usr/bin/colrm 5`

# Attempt to read the current airport network for the current OS

if [ "$OS" == "10.5" ]; then
	SSID=`/usr/sbin/networksetup -getairportnetwork | sed 's/Current AirPort Network: //g' | grep -v "GenenAir" | grep -v "guestwlan" > /private/var/tmp/.mifiCheck`
fi

if [ "$OS" == "10.6" ]; then
	SSID=`/usr/sbin/networksetup -getairportnetwork AirPort | sed 's/Current AirPort Network: //g' | grep -v "GenenAir" | grep -v "guestwlan" > /private/var/tmp/.mifiCheck`
fi

if [ "$OS" == "10.7" ] || [ "$OS" == "10.8" ]; then
	device=`/usr/sbin/networksetup -listallhardwareports | grep -A 1 Wi-Fi | awk '/Device/{ print $2 }'` 
	SSID=`/usr/sbin/networksetup -getairportnetwork $device | sed 's/Current Wi-Fi Network: //g' | grep -v "GenenAir" | grep -v "guestwlan" > /private/var/tmp/.mifiCheck` 
fi

# Ensure that AirPort was found
hasAirPort=`wc /private/var/tmp/.mifiCheck | awk '{print$1}' | grep 0`

if [ "$hasAirPort" = "" ]; then
	if [ "$OS" == "10.7" ] || [ "$OS" == "10.8" ]; then
		MiFiGateway=`networksetup -getinfo "Wi-Fi" | grep "Router:" | grep -v "IPv6" | awk '{print$2}'`
	else
		MiFiGateway=`networksetup -getinfo "AirPort" | grep "Router:" | grep -v "IPv6" | awk '{print$2}'`
	fi
	if [ "$MiFiGateway" != "none" ] || [ "$MiFiGateway" != "" ]; then
		curl http://$MiFiGateway/index.html -L | grep -q "Sierra"
		if [ "$?" == "0" ]; then
			MiFiStatus="TRUE"
		else		
			curl http://$MiFiGateway/index.html -L | grep -q "MiFi"
			if [ "$?" == "0" ]; then
				MiFiStatus="TRUE"
			else
				MiFiStatus="FALSE"
			fi
		fi
	fi
fi

wwan=`networksetup -listnetworkserviceorder | grep "wwan" | cut -d "," -f1 | sed 's/(Hardware Port: //g'`
if [ "$wwan" != "" ]; then
	wwanGateway=`networksetup -getinfo "$wwan" | grep "Router:" | grep -v "IPv6" | awk '{print$2}'`
	if [ "$wwanGateway" != "none" ] || [ "$wwanGateway" != "" ]; then
		if [ "$wwanGateway" != "none" ] || [ "$wwanGateway" != "" ]; then
			curl http://$wwanGateway/index.html -L | grep -q "Sierra"
			if [ "$?" == "0" ]; then
				WWANStatus="TRUE"
			else
				curl http://$wwanGateway/index.html -L | grep -q "MiFi"
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
	echo "<result>WWAN</result>"
else
	if [ "$MiFiStatus" = "TRUE" ]; then
		echo "<result>MiFi</result>"
	else
		echo "<result>NONE</result>"
	fi
fi

exit 0