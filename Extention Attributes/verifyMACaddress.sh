#!/bin/sh

## Enter variables for API

apiUsername="username"
apiPassword="password"

## Do not modify below this line ##

myJSS=`defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url`
myMac=`ifconfig | grep -m 1 ether | awk '{print $2}' | sed s/:/./g`

resultFromAPI=`curl -k --silent -u "$apiUsername":"$apiPassword" "$myJSS"JSSResource/computers/macaddress/"$myMac"/subset/general | grep "<computer>"`

echo $resultFromAPI

if [ "$resultFromAPI" == "" ]; then
	echo "<result>false</result>"
else
	echo "<result>true</true>"
fi