#!/bin/sh
# ginstall_recon.sh
#
#

declare -x CocoaDialog="/private/var/gne/gInstall/bin/cocoaDialog.app/Contents/MacOS/cocoaDialog"

rm -f /tmp/hpipe
mkfifo /tmp/hpipe
$CocoaDialog progressbar --icon-file "/var/gne/gInstall/icons/MacDNA.icns" --float --title "gInstall Inventory Update" --text "Running Recon......." --icon-height "92" --icon-width "92" --width "500" --height "132" --indeterminate < /tmp/hpipe &
exec 3<> /tmp/hpipe

jamf recon

exec 3>&-
wait
rm -f /tmp/hpipe