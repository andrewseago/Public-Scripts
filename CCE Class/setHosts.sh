#!/bin/sh
# setHosts.sh
#
#
# Created by andrewws on 04/15/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
targetVolume="$3"

echo "192.168.102.143 jss.seagonet.net" >> "$targetVolume/etc/hosts"
echo "192.168.102.144 jds.seagonet.net" >> "$targetVolume/etc/hosts"
echo "192.168.102.145 netsus.seagonet.net" >> "$targetVolume/etc/hosts"
echo "192.168.102.146 macdp.seagonet.net" >> "$targetVolume/etc/hosts"
