#!/bin/sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute
ExistingCasperShare=`sharing -l | grep "path\:" | sed 's/path:		//'`
echo "<result>$ExistingCasperShare</result>"


#ea_display_name	Service - Filesharing Paths
