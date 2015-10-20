#!/bin/sh
# exta_server_app_version.sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
ServerVersion=`defaults read /Applications/Server.app/Contents/Info.plist CFBundleShortVersionString`
echo "<result>$ServerVersion</result>"


#ea_display_name	Server - App Version
