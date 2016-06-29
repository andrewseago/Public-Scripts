#!/bin/sh
# 1_Hardware_Inventory
#
#
# Created by andrewws on 04/05/16.

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
# Variables used by this script
rootPath="/var/AutoMagic/git_repos/rhel_6_exta"
hostname=`hostname`
computerXmlPath="$1"
dmidecode_path="/usr/sbin/dmidecode"
if [ -e /etc/centos-release ]; then
	os_name='CentOS'
	os_version=`awk '{print$3}' /etc/centos-release`
	os_build=`awk '{print$3}' /etc/centos-release`
elif [ -e /etc/redhat-release ]; then
	os_name='Red Hat Enterprise Linux Server'
	os_version=`awk '{print$7}' /etc/redhat-release`
	os_build=`awk '{print$7}' /etc/redhat-release`
else
	osVersionCheck="NA"
fi
processor_speed=`grep "cpu MHz" /proc/cpuinfo | cut -d ':' -f2 | sed 's/ //' | cut -d '.' -f1 | tail -n 1`
processor_speed_mhz=`grep "cpu MHz" /proc/cpuinfo | cut -d ':' -f2 | sed 's/ //' | cut -d '.' -f1 | tail -n 1`
number_processors=`grep "processor" /proc/cpuinfo | wc -l`
processor_architecture=`lscpu | awk '/Architecture:/{print$2}' | tail -n 1`
total_ram=`free -m | awk '/Mem/{print$2}'`
total_ram_mb=`free -m | awk '/Mem/{print$2}'`
processor_type=`grep 'model name' /proc/cpuinfo | cut -d ':' -f2 | sed 's/ //' | awk '{print$1, $2, $4}' | tail -n 1`
boot_volume=`mount | grep "on / type" | awk '{print$1}'`
boot_volume_size=`df -Pm $boot_volume | tail -n 1 | awk '{print$2}'`
boot_volume_partition_capacity_mb=`df -Pm $boot_volume | tail -n 1 | awk '{print$2}'`
boot_volume_disk_used=`df -Pm $boot_volume | tail -n 1 | awk '{print$3}'`
boot_volume_disk_availible=`df -Pm $boot_volume | tail -n 1 | awk '{print$4}'`
boot_volume_disk_percent_used=`df -Pm $boot_volume | tail -n 1 | awk '{print$5}'`
nfs_volume=`mount | grep nfs | grep 'addr=' | awk '{print$3}'`
if [ ! -z ${nfs_volume+x} ]; then
	nfs_volume_size=`df -Pm $nfs_volume | tail -n 1 | awk '{print$2}'`
	nfs_volume_partition_capacity_mb=`df -Pm $nfs_volume | tail -n 1 | awk '{print$2}'`
	nfs_volume_disk_used=`df -Pm $nfs_volume | tail -n 1 | awk '{print$3}'`
	nfs_volume_disk_availible=`df -Pm $nfs_volume | tail -n 1 | awk '{print$4}'`
	nfs_volume_disk_percent_used=`df -Pm $nfs_volume | tail -n 1 | awk '{print$5}'`
fi
nic_speed=`/sbin/ethtool eth0 | grep "Speed:" | awk '{print$2}'`
ip_address=`grep IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0 | cut -d '=' -f2 | sed 's/"//g'`
make=`$dmidecode_path -s system-manufacturer`
if [ -z ${make+x} ]; then
	make="VMware, Inc."
	model="VMware Virtual Platform"
	model_identifier="None"
else
	model=`$dmidecode_path -s system-product-name`
	model_identifier=`$dmidecode_path -s system-version`
fi
## Script
####################################################################################################
## Basic Info
xmlstarlet ed --inplace -u  '/computer/hardware/make' -v "$make" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/model' -v "$model" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/model_identifier' -v "$model_identifier" "$computerXmlPath"
## Network
xmlstarlet ed --inplace -u  '/computer/hardware/nic_speed' -v "$nic_speed" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/general/ip_address' -v "$ip_address" "$computerXmlPath"
## OS Info
xmlstarlet ed --inplace -u  '/computer/hardware/os_name' -v "Mac OS X" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/os_version' -v "$os_version" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/os_build' -v "$os_name" "$computerXmlPath"
## CPU
xmlstarlet ed --inplace -u  '/computer/hardware/processor_type' -v "$processor_type" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/processor_architecture' -v "$processor_architecture" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/number_processors' -v "$number_processors" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/processor_speed' -v "$processor_speed" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/processor_speed_mhz' -v "$processor_speed_mhz" "$computerXmlPath"
## RAM
xmlstarlet ed --inplace -u  '/computer/hardware/total_ram' -v "$total_ram" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/total_ram_mb' -v "$total_ram_mb" "$computerXmlPath"
## Storage Info
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/size' -v "$boot_volume_size" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/drive_capacity_mb' -v "$boot_volume_size" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/partition/size' -v "$boot_volume_size" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/partition/partition_capacity_mb' -v "$boot_volume_size" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/partition/percentage_full' -v "$boot_volume_disk_percent_used" "$computerXmlPath"
xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk1" ]/partition/name' -v "$boot_volume" "$computerXmlPath"
if [ ! -z ${nfs_volume+x} ]; then
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/size' -v "$nfs_volume_size" "$computerXmlPath"
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/drive_capacity_mb' -v "$nfs_volume_size" "$computerXmlPath"
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/partition/size' -v "$nfs_volume_size" "$computerXmlPath"
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/partition/partition_capacity_mb' -v "$nfs_volume_size" "$computerXmlPath"
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/partition/percentage_full' -v "$nfs_volume_disk_percent_used" "$computerXmlPath"
	xmlstarlet ed --inplace -u  '/computer/hardware/storage/device[ disk = "disk2" ]/partition/name' -v "$nfs_volume" "$computerXmlPath"
fi
