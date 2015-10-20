#!/bin/sh
# Set_SUS.sh
#
#	Checks and Applies the Computers SUS Server that is assigned to the systems current subnet
# Created by Andrew Seago on 11/13/13.
# Updated by Andrew Seago on 10/19/2015
#
# set -x  # DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################

date=`date "+%Y-%m-%d"`
DefaultSUSserver="http://sus.acme.com"
jamf=/usr/sbin/jamf
OS=`sw_vers -buildVersion | /usr/bin/colrm 3`
apiUsername=""
apiPassword=""
susURL=""
jssAddress=`defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url`
CatalogURL=""
SUSserver=""
SystemUDID=`system_profiler SPHardwareDataType | grep 'Hardware UUID:' | awk '{print$3}'`
objectExists=`curl -k -s -u "$jssUSER_Destination":"$jssPASSWORD_Destination" "$jssURL_Destination/$jss2jssAPItable/udid/$SystemUDID"`
## Functions
####################################################################################################
function jssAvalible () {
	JSS1avalible=$(curl -ks -I "$jssAddress"/selfservice2/ 2>|/dev/null | awk '/^HTTP/ { print $2 }' | sed -e 's/[[:cntrl:]]//')
	if [ "$JSS1avalible" = "200" ]; then
		jssAddress="$jssAddress"
	else
		exit 0
	fi
}



function getCatalogURL () {
	if [ "$OS" == "10" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-leopard-snowleopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "11" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "12" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "13" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "14" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "15" ]; then
		CatalogURL="$susServer/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
}

function GetDefaultSusCatalogURL () {
	if [ "$OS" == "10" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-leopard-snowleopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "11" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "12" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "13" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "14" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
	if [ "$OS" == "15" ]; then
		DefaultCatalogURL="$DefaultSUSserver/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog"
	fi
}

function findSUS () {
	susID=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/computers/udid/$SystemUDID/subset/General -X GET | sed -e 's,.*<sus>\([^<]*\)</sus>.*,\1,g' | awk '{print$1}'`
	susURL=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/softwareupdateservers/name/"$susID" -X GET | sed -e 's,.*<ip_address>\([^<]*\)</ip_address>.*,\1,g' | awk '{print$1}'`
	susURLExist=`echo "$susURL" | grep '<html>'`
	if [ "$susURLExist" != "" ]; then
		susURL=""
	fi
	susPort=`curl -ks -u "$apiUsername":"$apiPassword" "$jssAddress"JSSResource/softwareupdateservers/name/"$susID" -X GET | sed -e 's,.*<port>\([^<]*\)</port>.*,\1,g' | awk '{print$1}'`
	if [[ "$susPort" == 80 ]]; then
		susPort=""
	else
		susPort=":$susPort"
	fi
}

function SetSUS () {
	if [ "$susURL" = "" ]; then
		defaultSUSavalible=$(curl -I "$DefaultSUSserver/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1_prod.sucatalog" 2>|/dev/null | awk '/^Content-Type:/ { print $2 }' | sed -e 's/[[:cntrl:]]//')
		if [ "$defaultSUSavalible" != "text/xml" ]; then
			exit 0
		else
			declare -x susServer="$DefaultSUSserver"
			GetDefaultSusCatalogURL
			`defaults write /Library/Preferences/com.apple.SoftwareUpdate CatalogURL $DefaultCatalogURL`
			`defaults write /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL $DefaultCatalogURL`
			if [[ "$OS" == "10.9" ]] || [[ "$OS" == "10.1" ]]; then
				killall softwareupdated
else
killall softwareupdate
			fi
			exit 0
		fi
	else
		declare -x susServer="http://$susURL$susPort"
		getCatalogURL
		`defaults write /Library/Preferences/com.apple.SoftwareUpdate CatalogURL "$CatalogURL"`
		`defaults write /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL "$CatalogURL"`
		if [ "$OS" == "13" ] || [ "$OS" == "14" ] || [ "$OS" == "15" ]; then
			killall softwareupdated
else
killall softwareupdate
		fi
		exit 0
	fi
}

## Script
####################################################################################################
## Get JSSID
jssAvalible
findSUS
SetSUS

exit 0		## Success
