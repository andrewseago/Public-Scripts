#!/bin/sh
# exta_logsize.sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
varlog=`du  -h -d 0 /var/log | awk '{print$1}'`
librarylog=`du  -h -d 0 /Library/Logs | awk '{print$1}'`
## Script
####################################################################################################
echo "<result>Var Logs\: $varlog Library Logs: $librarylog</result>"


#ea_display_name	Log Sizes
