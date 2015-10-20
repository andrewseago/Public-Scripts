#!/bin/sh
# getDnsServers.sh
#
#
# Created by Andrew Seago on 05/13/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
dnsServers=`awk '/nameserver/{print$2}' /etc/resolv.conf`

## Script
####################################################################################################
echo "<result>$dnsServers</result>"


#ea_display_name	Server - DNS Servers
