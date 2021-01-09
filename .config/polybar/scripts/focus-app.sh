#! /bin/bash 
##### Leaving this here as a todo and not relevant any more
##### Patched dwm with focus active patch and warp
##### This is replaced using `goto-app`

# Note: I am on a 3 monitor setup and will almost always call this script from the main middle
# middle monitor. Also with DWM setup, will always know which monitor the app I want to focus 
# will be. 
#
# To that effect, I have taken the easy way out and focsing left or right of main. Ideally DWM
# would be patched to allow selection by monitor number, or parse through dwm-msg outputs to find
# the monitor and change focus a number of times to reach target monitor
#
# This script Script to find the client ID in DWM for a process.
# 1. checks if the process is running and runs if not
# 2. Runs process and sleeps for a few seconds to give appliction a chance to create a client window. Increase time if needed that suits your system
# 3. Focus to the left or right monitor
# 4. Use dwm-mesg (IPC Patched DWM) to focus to monitor and then view tag with client (TODO, test if on multiple tags)

# Dependencies: jq, dwm (IPC Patched), IPC commands: focusmon and view, wmctrl

# TODO, add invalid argument handling
processName="$1"
windowName="$2"
monitorDirection="$3"
waitTime=3
tagNum=

if ! pgrep -x $processName; then 
  $processName &
  sleep $waitTime
fi

# Focus to the monitor >0 to move right, <0 to move left
case $3 in 
 left) $(dwm-msg run_command focusmon -1) ;;
 right) $(dwm-msg run_command focusmon 1) ;;
esac

# Get the client ID to focus on that tag
clientData=$(echo $(( $(wmctrl -l | grep $windowName | cut -d' ' -f1) )) | xargs dwm-msg get_dwm_client)
# echo $clientData
tagNum=$(echo $clientData | jq '.tags')
# echo "tagNum: $tagNum"
$(dwm-msg run_command view $tagNum)


### My older (partial) attempt to find the monitor, will come back to it later to make it work for any setup
# monNum=
# monNum=$(echo $clientData | jq '.monitor_number')
# echo "MonNum: $monNum"
# monitors=$(dwm-msg get_monitors)
# numberOfMonitors=$(echo $monitors | jq length)
# echo "Number of Monitors: $numberOfMonitors"
# dwm-msg get_monitors > /tmp/mons.json
# mons=$(jq '.[].num' /tmp/mons.json)

#for monNum in ${mons[@]}; do
#  echo $monNum
#done