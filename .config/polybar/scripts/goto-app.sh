#! /bin/bash 

# TODO, add invalid argument handling
processName="$1"
windowName="$2"
waitTime=3

if ! pgrep -x $processName; then 
  $processName &
  sleep $waitTime
fi

wmctrl -a $windowName