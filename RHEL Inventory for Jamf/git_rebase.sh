#!/bin/sh
# git_rebase.sh
#
#
# Created by andrewws on 04/05/16.
# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
gitPath='/var/AutoMagic/git_repos/rhel_6_exta'
gitBranch=`xmlstarlet sel -t -v "/computer/gitBranch" /var/AutoMagic/configs/AutoMagic.xml`
## Script
####################################################################################################
cd $gitPath
git fetch --all
git reset --hard origin/$gitBranch
git checkout $gitBranch
git pull
exit 0
