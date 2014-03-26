#!/bin/sh
# Set_SUS.sh
# 
# Description: This script uses the assigned Software Update Servers in Casper to correctly set the systems full sucatalog url 
#
# Created by andrewws on 06/13/13.

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
logFile="/private/var/log/setSUS.log"
logname="/private/var/tmp/.susLog"
date=`date "+%Y-%m-%d"`
DefaultSUSserver="ENTER DEFAULT SUS URL AND PORT HERE"
jamf=/usr/sbin/jamf
OS=`/usr/bin/sw_vers -productVersion | /usr/bin/colrm 5`
jssIDlog="/private/var/tmp/.jssid"
jssID=`cat "$jssIDlog"`
# API user that has minimal API read only access
apiUsername="ENTER USERNAME HERE"
apiPassword="ENTER PASSWORD HERE"
susURL=""
jssAddress=`defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url`
CatalogURL=""
SUSserver=""

## Functions
####################################################################################################
## log function
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logFile	
}

## This run's reo
function jamfRecon () {
# Run Recon and update userInfo if possible
	if [ "$UserName" = "" ]; then
		$jamf recon >> "$logname"
	else
		$jamf recon -endUsername "$UserName" -email "$Email" -room "$Site" -phone "$PhoneNumber" >> "$logname"
	fi
}

## This checks to see if the JSS is reachable. If not it terminates the script
function jssAvalible () {
	JSS1avalible=$(curl -ks -I "$jssAddress"apiFrontPage.rest 2>|/dev/null | awk '/^HTTP/ { print $2 }' | sed -e 's/[[:cntrl:]]//')
	if [ "$JSS1avalible" = "200" ]; then
		jssAddress="$jssAddress"
	else
		exit 0
	fi
}

## Attempts to find the correct SUS server leveraging the Casper API
function findSUS () {
	susID=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/computers/id/$jssID/subset/General -X GET | sed -e 's,.*<sus>\([^<]*\)</sus>.*,\1,g' | awk '{print$1}'`
	susURL=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/softwareupdateservers/name/"$susID" -X GET | sed -e 's,.*<ip_address>\([^<]*\)</ip_address>.*,\1,g' | awk '{print$1}'`
	susPort=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/softwareupdateservers/name/"$susID" -X GET | sed -e 's,.*<port>\([^<]*\)</port>.*,\1,g' | awk '{print$1}'`
}

## Sets the variable for the correct sucatalog and branch
function getCatalogURL () {
	if [[ "$OS" = "10.6" ]]; then
		CatalogURL="$susServer/content/catalogs/others/index-leopard-snowleopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.5" ]]; then
		CatalogURL="$susServer/content/catalogs/others/index-leopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.7" ]]; then
		CatalogURL="$susServer/content/catalogs/others/index-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.8" ]]; then
		CatalogURL="$susServer/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
}

## Sets the variable for the if all else fails default sucatalog and branch
function GetDefaultSusCatalogURL () {
	if [[ "$OS" = "10.6" ]]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-leopard-snowleopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.5" ]]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-leopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.7" ]]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [[ "$OS" = "10.8" ]]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
}



## Script
####################################################################################################
rm -f $jssIDlog
## Get JSSID and run Recon
if [ -f "$jssIDlog" ]; then
	if [ "$jssID" = "" ] || [ "$jssID" = "N/A" ]; then
		echo "$date" > "$logname"
		jamfRecon
		grep -m1 "computer" $logname | awk -F"<computer_id>" '{ print $2 }' | awk -F"</computer_id>" '{ print $1 }' > "$jssIDlog"
		jssID=`cat "$jssIDlog"`
	fi
else
	if [ -d "/var/gne" ]; then
		echo "$date" > "$logname"
		jamfRecon
		grep -m1 "computer" $logname | awk -F"<computer_id>" '{ print $2 }' | awk -F"</computer_id>" '{ print $1 }' > "$jssIDlog"
		jssID=`cat "$jssIDlog"`
	else
		mkdir "/var/gne"
		echo "$date" > "$logname"
		jamfRecon
		grep -m1 "computer" $logname | awk -F"<computer_id>" '{ print $2 }' | awk -F"</computer_id>" '{ print $1 }' > "$jssIDlog"
		jssID=`cat "$jssIDlog"`
	fi
fi
jssAvalible
findSUS



if [ "$susURL" = "<?xml" ]; then
	log "SUS not found in JSS"
	log "Using $DefaultSUSserver"
	defaultSUSavalible=$(curl -I "$DefaultSUSserver" 2>|/dev/null | awk '/^Content-Type:/ { print $2 }' | sed -e 's/[[:cntrl:]]//')
	if [ "$defaultSUSavalible" != "text/plain" ]; then
		log "Unable to contact $DefaultSUSserver"	
		exit 0
	else
		log "Contacted $DefaultSUSserver"
		declare -x susServer="$DefaultSUSserver"
		GetDefaultSusCatalogURL
		`defaults write /Library/Preferences/com.apple.SoftwareUpdate CatalogURL $DefaultCatalogURL`
		`defaults write /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL $DefaultCatalogURL`
		exit 0
	fi
else
	declare -x susServer="http://$susURL:$susPort"
	getCatalogURL
	`defaults write /Library/Preferences/com.apple.SoftwareUpdate CatalogURL $CatalogURL`
	`defaults write /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL $CatalogURL`
	exit 0
fi

exit 0	

