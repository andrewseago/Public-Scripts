#!/bin/sh
# set -x
sourceSize=6683840
targetPath='/Volumes/TimeMachine3TB/Library'
while [ "$(pgrep "rsync")" != '' ]; do
    downloadProgress=$(du -d 0 -k $targetPath | awk '{print$1}')
    precent=$(echo "$downloadProgress" "$sourceSize" | awk '{print$1/$2*100}' | cut -d "." -f1)
    clear
    echo "Transfer is at $precent%"
    declare -i downloadProgressI=$downloadProgress
    declare -i sourceSizeI=$sourceSize
    amountLeftM=`expr $sourceSizeI - $downloadProgressI | awk '{print$1/1024}'`
    echo "$amountLeftM MB Remaining"
    amountLeftG=`expr $sourceSizeI - $downloadProgressI | awk '{print$1/1048576}'`
    echo "$amountLeftG GB Remaining"
    timeLeft=`echo $amountLeftM | awk '{print$1/3600}'`
    echo "$timeLeft minutes Remaining"
    echo "Next update in 5 seconds"
    sleep 1
    echo "Next update in 4 seconds"
    sleep 1
    echo "Next update in 3 seconds"
    sleep 1
    echo "Next update in 2 seconds"
    sleep 1
    echo "Next update in 1 seconds"
    sleep 1
done
