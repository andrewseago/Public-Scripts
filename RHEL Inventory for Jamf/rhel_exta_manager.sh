#!/bin/sh
# rhel_exta_manager.sh
#
#
# Created by andrewws on 04/05/16.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
logFile="/var/log/rhel_exta_manager.log"
rootPath="/var/AutoMagic/git_repos/rhel_6_exta"
extasFolder="$rootPath/extas"
jssUDID=`xmlstarlet sel -t -v "/computer/jssUDID" /var/AutoMagic/configs/AutoMagic.xml`
jssName=`xmlstarlet sel -t -v "/computer/jssName" /var/AutoMagic/configs/AutoMagic.xml`
jssMAC=`xmlstarlet sel -t -v "/computer/jssMAC" /var/AutoMagic/configs/AutoMagic.xml`
jssSerial=`xmlstarlet sel -t -v "/computer/jssSerial" /var/AutoMagic/configs/AutoMagic.xml`
jssURL=`xmlstarlet sel -t -v "/computer/jssURL" /var/AutoMagic/configs/AutoMagic.xml`
jssUser=`xmlstarlet sel -t -v "/computer/jssUser" /var/AutoMagic/configs/AutoMagic.xml`
jssUserPass=`xmlstarlet sel -t -v "/computer/jssUserPass" /var/AutoMagic/configs/AutoMagic.xml`
gitBranch=`xmlstarlet sel -t -v "/computer/gitBranch" /var/AutoMagic/configs/AutoMagic.xml`
jssid=`curl -s -k -u "$jssUser":"$jssUserPass" "$jssURL/JSSResource/computers/udid/$jssUDID/subset/general" -X GET | xmllint --format - | xmlstarlet sel -t -v /computer/general/id`
jssSystemType=`grep -i "jss" <<< $jssName`
jdsSystemType=`grep -i "jds" <<< $jssName`
MySQLSystemType=`grep -i 'mysql\|db' <<< $jssName`
if [ ! -z ${MySQLSystemType+x} ]; then
	systemType="MySQL"
elif [ ! -z ${jdsSystemType+x} ]; then
	systemType="JDS"
elif [ ! -z ${jssSystemType+x} ]; then
	systemType="JSS"
fi
groupName="$gitBranch%20-%20$systemType"
computerXmlPath="$rootPath/xml/computer_core.xml"
computerGroupXmlPath="$rootPath/xml/computer_group.xml"
DEBUGmode='OFF'
## Functions
####################################################################################################
log(){
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile
}
function RunExtas () {
	# Run Settings Scripts
	echo "####################################################################################################" >> "$logFile"
	log "Getting Updates"
	/var/AutoMagic/git_repos/rhel_6_exta/git_rebase.sh >> "$logFile"
	echo "Starting Settings Updates" >> "$logFile"
	for func in `ls "$extasFolder" | grep .sh`; do
		echo "---------------------------------------------------------------" >> "$logFile"
    if [ "$DEBUGmode" == "ON" ]; then
      log "Starting DEBUGmode for $extasFolder/$func"
      sh -x "$extasFolder"/"$func" "$computerXmlPath" >> "$logFile" 2>&1
    else
      "$extasFolder"/"$func" "$computerXmlPath" >> "$logFile"  2>&1
    fi
		if [ "$?" = "0" ]; then
			log "$func completed"
		else
			log "$func completed with errors"
		fi
		sleep 1
		echo "---------------------------------------------------------------" >> "$logFile"
	done
}
function UpdateJSS () {
		xmlstarlet ed --inplace -u /computer/general/name -v "$jssName" "$computerXmlPath"
		xmlstarlet ed --inplace -u /computer/general/mac_address -v "$jssMAC" "$computerXmlPath"
		xmlstarlet ed --inplace -u /computer/general/serial_number -v "$jssSerial" "$computerXmlPath"
		xmlstarlet ed --inplace -u /computer/general/udid -v "$jssUDID" "$computerXmlPath"
		xmlstarlet ed --inplace -u "/computer/extension_attributes/extension_attribute[id=38]/value" -v "$gitBranch" "$computerXmlPath"
		sleep 2
		UpdateObject=`curl -s -k -I -u "$jssUser":"$jssUserPass" "$jssURL/JSSResource/computers/udid/$jssUDID" -X PUT -T "$computerXmlPath"  | grep "HTTP/1.1 201"`
		if [ "$UpdateObject" == "" ]; then
			log "ERROR: Unable to update or create JSSResource/computers/id/$jssid"
			exit 1
		else
			log "EXTA Update Complete"
		fi
}
function UpdateComputerGroupsJSS () {
	if [ ! -z ${jssid+x} ]; then
		curl -s -k -u "$jssUser":"$jssUserPass" "$jssURL/JSSResource/computergroups/id/18" -X GET | xmllint --format - > "$computerGroupXmlPath"
		exitCode="$?"
		if [ "$exitCode" != "0" ]; then
			log "Group XML Download Failed"
			return
		fi
		groupID='18'
		xmlstarlet ed --inplace -d /computer_group/computers/size "$computerGroupXmlPath"
		xmlstarlet ed --inplace --subnode /computer_group/computers --type elem -n id -v "$jssid" "$computerGroupXmlPath"
		UpdateObject=`curl -s -k -I -u "$jssUser":"$jssUserPass" "$jssURL/JSSResource/computergroups/id/$groupID" -X PUT -T "$computerGroupXmlPath"  | grep "HTTP/1.1 201"`
		if [ "$UpdateObject" == "" ]; then
			log "ERROR: Unable to update or create $jssURL/JSSResource/computergroups/id/$groupID"
			exit 1
		else
			log "Group Membership Update Complete"
		fi
	else
		log "No JSSID Found"
		return
	fi

}


## Script
####################################################################################################
RunExtas
UpdateJSS
UpdateComputerGroupsJSS
