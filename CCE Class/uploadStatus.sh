#!/bin/sh
# uploadStatus.sh
#
#
# Created by andrewws on 04/14/15.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
CPU_USAGE=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'`
CONN=`netstat -nt | awk '{ print $5}' | cut -d: -f1 | sed -e '/^$/d' | sort -n | uniq | wc -l`
BR1=`cat /sys/class/net/eth0/statistics/rx_bytes`
BT1=`cat /sys/class/net/eth0/statistics/tx_bytes`
INKB=$(((($BR1) /30) /1024))
OUTKB=$(((($BT1) /30) /1024))
MySQL_Connections=`mysqladmin -v -uroot -proot processlist | grep "jamfsoftware" | wc -l`
FreeRam=`awk '/MemFree:/{print$2}' < /proc/meminfo`
TotalRam=`awk '/MemTotal:/{print$2}' < /proc/meminfo`
UsedRam=$(($TotalRam-$FreeRam))
FreeDiskSpace=`df -h | awk '/sda1/{print$4}'`
Date=`date "+%Y-%m-%d %H:%M:%S"`
XML_Template='<?xml version="1.0" encoding="UTF-8"?><peripheral><general><id>272</id><bar_code_1>0</bar_code_1><bar_code_2>0</bar_code_2><type>JSS Server</type><fields><field><name>Update Time</name><value>DATEUPDATED</value></field><field><name>Free Diskspace</name><value>FREEDISK</value></field><field><name>Server Name</name><value>jss.seagonet.net</value></field><field><name>Memory Usage</name><value>RAMUSAGE</value></field><field><name>MySQL Connections</name><value>MYSQLCONNECTIONS</value></field><field><name>Bandwidth</name><value>BANDWIDTHUSAGE</value></field><field><name>CPU Usage</name><value>CPUUSAGEPERCENT</value></field></fields><site><id>-1</id><name>None</name></site><computer_id>-1</computer_id></general><location><username/><real_name/><email_address/><position/><phone/><department/><building/><room/></location><purchasing><is_purchased>true</is_purchased><is_leased>false</is_leased><po_number/><vendor/><applecare_id/><purchase_price/><purchasing_account/><po_date/><po_date_epoch>0</po_date_epoch><po_date_utc/><warranty_expires/><warranty_expires_epoch>0</warranty_expires_epoch><warranty_expires_utc/><lease_expires/><lease_expires_epoch>0</lease_expires_epoch><lease_expires_utc/><life_expectancy>0</life_expectancy><purchasing_contact/></purchasing><attachments/></peripheral>'
## Script
####################################################################################################
echo "$XML_Template" > /home/ladmin/serverstatus.xml
sed -i -e "s,RAMUSAGE,TotalRam: $TotalRam KB UsedRam: $UsedRam KB FreeRam: $FreeRam KB," "/home/ladmin/serverstatus.xml"
sed -i -e "s,MYSQLCONNECTIONS,$MySQL_Connections," "/home/ladmin/serverstatus.xml"
sed -i -e "s,BANDWIDTHUSAGE,INKB: $INKB OUTKB: $OUTKB," "/home/ladmin/serverstatus.xml"
sed -i -e "s,CPUUSAGEPERCENT,$CPU_USAGE," "/home/ladmin/serverstatus.xml"
sed -i -e "s,FREEDISK,$FreeDiskSpace," "/home/ladmin/serverstatus.xml"
sed -i -e "s,DATEUPDATED,$Date," "/home/ladmin/serverstatus.xml"

curl -k -u ladmin:jamf1234 https://jss.seagonet.net:8443/JSSResource/peripherals/id/272 -X PUT -T /home/ladmin/serverstatus.xml
