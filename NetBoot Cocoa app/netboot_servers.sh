#!/bin/sh
# netbootServers.sh
# 
#	This script should be uploaded to your Casper DP 
#
# Created by andrewws on 01/08/13.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

path=`pwd`
iconGlobe="$path/appIcon.icns"
CD="$path/CocoaDialog.app/Contents/MacOS/CocoaDialog"
#Netboot Config
NetbootNBI="CasperNetboot.nbi"
NetbootDMG="NetBoot.dmg"
NetbootPath="NetBoot/NetBootSP0"

# Dialog to choose which netboot server Replace the name and IP of your netboot servers
choose=`"$CD" dropdown --title "Casper Netboot Utility" --text "Choose Your Netboot Server:" --icon-file "$iconGlobe" --items \
"Basel (10.113.14.181)" \
"Madrid (10.120.66.23)" \
"Mississauga (151.120.32.148)" \
"Shanghai (10.113.14.181)" \
"Santa Clara (10.35.101.8)" \
"South San Francisco (10.36.29.103)" \
"Redwood City (128.137.25.165)" \
"Vacaville (128.137.25.165)" \
"Warsaw (145.245.230.25)" \
 --button1 Netboot --button2 Quit --string-output`

button=$(echo "${choose}" | awk 'NR==1{print}');
NetbootServer=`echo "${choose}" | awk 'NR>1{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

if [ "$button" = "Quit" ]; then
	exit 0
fi

bless --netboot --booter tftp://$NetbootServer/$NetbootPath/$NetbootNBI/i386/booter --kernel tftp://$NetbootServer/$NetbootPath/$NetbootNBI/i386/mach.macosx --kernelcache tftp://$NetbootServer/$NetbootPath/$NetbootNBI/i386/x86_64/kernelcache --options "rp=nfs:$NetbootServer:/private/tftpboot/$NetbootPath:$NetbootNBI/$NetbootDMG" --nextonly
rebootPrompt=`$CD msgbox --title "Casper Netboot Utility" --text "Neboot Server has been set" --button1 "Restart Now" --button2 "Cancel" --icon-file "$iconGlobe" --string-output`
buttonRB=$(echo "${rebootPrompt}" | awk 'NR==1{print}');

if [ "$buttonRB" = "Restart Now" ]; then
	shutdown -r now
fi

exit 0
