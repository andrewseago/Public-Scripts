# CocoaDialogFunctions.config
#
#	This script should be sourced into any other scripts needing CocoaDialogFunctions
#	
# Created by andrewws on 06/30/14.
# Updated by andrewws on 10/20/2015
# Copyright 2014 Genentech. All rights reserved.

## Variables
####################################################################################################
cocoaDialog_url="https://github.com/downloads/mstratman/cocoadialog/cocoaDialog_3.0.0-beta7.dmg"
CocoaDialog="/Library/Application Support/IT_Tools/cocoaDialog.app/Contents/MacOS/CocoaDialog"
CocoaDialogIcon="/Library/Application Support/IT_Tools/cocoaDialog.app/Contents/Resources/cocoadialog.icns"
button=""
StandardInputbox_Output=""
SecureStandardInputBox_Output=""
DropDown_Output=""
Checkbox_Output=""
## CocoaDialog Functions
####################################################################################################
function InstallCocoaDialog () {
	if [ ! -d "/Library/Application Support/IT_Tools/cocoaDialog.app" ];then
		curl -k -o /var/tmp/cocoaDialog.dmg "$cocoaDialog_url"
		hdiutil mount /var/tmp/cocoaDialog.dmg
		mkdir -f /Library/Application Support/IT_Tools
		cp -R /Volumes/cocoaDialog.app/cocoaDialog.app /Library/Application Support/IT_Tools/
		diskutil umount /Volumes/cocoaDialog.app
	fi
}

function StartProgressBar () {
	# $1=Title $2=Text $3=IconPath $4=Percent(Yes No) $5=Float(Yes No)
	# Percentage Example: echo "10 We are at 10%" > /tmp/hpipe
	title=$1
	text=$2
	icon=$3
	if [ "$4" == "Yes" ]; then
		percent="--percent"
	else
		percent='--indeterminate'
	fi
	if [ "$5" == "Yes" ]; then
		float='--float'
	elif [ "$5" == "No" ]; then
		float='--no-float'
	elif [ "$5" != "No" ] && [ "$5" != "Yes" ]; then
		float=''
	fi
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	"$CocoaDialog" progressbar  --title "$title" --text "$text" --icon-file "$icon" --icon-height 90 --icon-width 90 --width 512 --height 128 --debug "$percent" "$float" < /tmp/hpipe &
	exec 5<> /tmp/hpipe
	echo -n . >&5
}

function TerminateProgressBar () {
	exec 5>&-
	rm -f /tmp/hpipe
}

function PromptUser () {
	# $1=Title $2=Text $3=IconPath $4=Informative_Text
	# $5=Button1 $6=Button2
	button=""
	title=$1
	text=$2
	if [ "$3" == "" ]; then
		icon="$CocoaDialogIcon"
	else
		icon=$3
	fi
	informative_text="$4"
	if [ "$5" != "" ]; then
		button1="$5"
	else
		button1=""
	fi
	if [ "$6" != "" ]; then
		button2="$6"
	else
		button2=""
	fi
	user_dialog=`"$CocoaDialog" msgbox --title "$title" --text "$text" --icon-file "$icon" --informative-text "$informative_text" --float --button1 "$button1" --button2 "$button2"  --debug --icon-size 128 --width 524 --string-output`
	button=`echo "${user_dialog}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}

function StandardInputbox () {
	# $1=Title $2=informative_text $3=IconPath
	StandardInputbox_Output=""
	button=""
	title=$1
	informative_text=$2
	icon=$3
	user_dialog=`"$CocoaDialog" standard-inputbox --title "$title" --informative-text "$informative_text" --float --icon-file "$icon" --debug --string-output`
	button=`echo "${user_dialog}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
	StandardInputbox_Output=`echo "${user_dialog}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}

function SecureStandardInputBox () {
	# $1=Title $2=informative_text $3=IconPath
	SecureStandardInputBox_Output=""
	button=""
	title=$1
	informative_text=$2
	icon=$3
	user_dialog=`"$CocoaDialog" secure-standard-inputbox --title "$title" --informative-text "$informative_text" --string-output --float --icon-file "$icon" --debug`
	button=`echo "${user_dialog}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
	SecureStandardInputBox_Output=`echo "${user_dialog}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}

function PromptDropDown () {
	# $1=Title $2=Text $3=IconPath $4=Informative_Text
	# $5=Button1 $6=Button2
	button=""
	DropDown_Output=""
	title=$1
	text=$2
	if [ "$3" == "" ]; then
		icon="$CocoaDialogIcon"
	else
		icon=$3
	fi
	if [ "$4" != "" ]; then
		button1="$4"
	else
		button1=""
	fi
	if [ "$5" != "" ]; then
		button2="$5"
	else
		button2=""
	fi
	if [ "$6" != "" ]; then
		button3="$6"
	else
		button3=""
	fi
	item1=$7
	item2=$8
	item3=$9
	item4=${10}
	item5=${11}
	item6=${12}
	item7=${13}
	item8=${14}
	user_dialog=`"$CocoaDialog" dropdown --title "$title" --text "$text" --float --icon-file "$icon" --button1 "$button1" --button2 "$button2" --button3 "$button3" --items $item1 $item2 $item3 $item4 $item5 $item6 $item7 $item8--debug --string-output --icon-size 128 --width 512 --height 160`
	button=`echo "${user_dialog}" | awk 'NR==1' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
	DropDown_Output=`echo "${user_dialog}" | awk 'NR==2' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}
function StartDownloadProgressBar () {
	# $1=Title $2=Text $3=IconPath $4=Float(Yes No) $5=ManualTrigger $6=DownloadFileSize $7=DownloadFileName
	# Percentage Example: echo "10 We are at 10%" > /tmp/hpipe
	title=$1
	text=$2
	if [ "$3" == "" ]; then
		icon="$CocoaDialogIcon"
	else
		icon=$3
	fi
	if [ "$4" == "Yes" ]; then
		float='--float'
	elif [ "$4" == "No" ]; then
		float='--no-float'
	elif [ "$4" != "No" ] && [ "$4" != "Yes" ]; then
		float=''
	fi
	ManualTrigger=$5
	DownloadFileSize=$6
	DownloadFileName=$7
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe
	"$CocoaDialog" progressbar  --title "$title" --text "$text" --icon-file "$icon" --icon-size 128 --width 512 --height 160 --debug --stoppable "$float" < /tmp/hpipe > /private/var/tmp/.progressOutput &
	exec 6<> /tmp/hpipe
	echo -n . >&6
	/usr/sbin/jamf policy -event "$ManualTrigger" &
	while [[ `ps -ae | grep "/usr/sbin/jamf policy -event $ManualTrigger" | grep -v grep | awk '{print$4}'` = "/usr/sbin/jamf" ]] && [[ `cat /private/var/tmp/.progressOutput` != "stopped" ]]; do
		downloadProgress=`du -k  /Library/Application\ Support/JAMF/Downloads/"$DownloadFileName" | awk '{print$1}'`
		precent=`echo "$downloadProgress" "$DownloadFileSize" | awk '{print$1/$2*100}' | cut -d "." -f1`
		progressBarOutput=`cat /private/var/tmp/.progressOutput`
		if [ "$precent" = "100" ]; then
			echo "$precent Please Wait Verifying Download.... $precent%" >&6
		else
			echo "$precent Download in Progress.... $precent%" >&6
		fi
		sleep .5
	done
	exec 6>&-
	rm -f /tmp/hpipe
	if [[ `cat /private/var/tmp/.progressOutput` == "stopped" ]]; then
		killall jamf
		killall jamf
		rm /private/var/tmp/.progressOutput
		exit 0
	else
		rm /private/var/tmp/.progressOutput
	fi
}

function PromptCheckbox () {
	# $1=Title $2=Text $3=IconPath $4=Informative_Text
	# $5=Button1 $6=Button2
	button=""
	Checkbox_Output=""
	title=$1
	text=$2
	if [ "$3" == "" ]; then
		icon="$CocoaDialogIcon"
	else
		icon=$3
	fi
	if [ "$4" != "" ]; then
		button1="$4"
	else
		button1=""
	fi
	if [ "$5" != "" ]; then
		button2="$5"
	else
		button2=""
	fi
	if [ "$6" != "" ]; then
		button3="$6"
	else
		button3=""
	fi
	item1=$7
	item2=$8
	item3=$9
	item4=${10}
	item5=${11}
	item6=${12}
	item7=${13}
	item8=${14}
	user_dialog=`"$CocoaDialog" checkbox --title "$title" --label "$text" --float --icon-file "$icon" --button1 "$button1" --button2 "$button2" --button3 "$button3" --items "$item1" $item2 $item3 $item4 $item5 $item6 $item7 $item8--debug --string-output --icon-size 128 --width 512 --height 160`
	button=`echo "${user_dialog}" | awk 'NR==1' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
	Checkbox_Output=`echo "${user_dialog}" | awk 'NR==2' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}
function PromptTextbox () {
	# $1=Title $2=TextFile Path $3=IconPath $4=Text
	# $5=Button1 $6=Button2 $7=Button3
	button=""
	title=$1
	TextFile=$2
	if [ "$3" == "" ]; then
		icon="$CocoaDialogIcon"
	else
		icon=$3
	fi
	text="$4"
	if [ "$5" != "" ]; then
		button1="$5"
	else
		button1=""
	fi
	if [ "$6" != "" ]; then
		button2="$6"
	else
		button2=""
	fi
	if [ "$7" != "" ]; then
		button3="$7"
	else
		button3=""
	fi
	user_dialog=`"$CocoaDialog" textbox --title "$title" --text-from-file "$TextFile" --label "$text" --float --icon-file "$icon" --button1 "$button1" --button2 "$button2" --button3 "$button3" --debug --string-output`
	button=`echo "${user_dialog}" | awk 'NR==1' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
}
## Script
####################################################################################################
InstallCocoaDialog
