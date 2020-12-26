#! /bin/bash 
# Work in Progress, non funtional
#
#
# Script to find the client ID in DWM for a process.
# 1. checks if the process is running and runs if not
# 2. sleeps for a few seconds to give appliction a chance to create a client window. Increase time if needed that suits your system
# 3. Use dwm-mesg (IPC Patched DWM) to find current foucsed monitor and target monitor
# 4. Use dwm-mesg (IPC Patched DWM) to focus to monitor and then view tag with client (TODO, test if on multiple tags)

# Dependencies: jq, dwm (IPC Patched), IPC commands: focusmon and view

processName="thunderbird"
windowName="Thunderbird"
waitTime=5
monNum=
tagNum=

if ! pgrep -x $processName; then 
  $($processName &)
fi

monitors=$(dwm-msg get_monitors)

numberOfMonitors=$(echo $monitors | jq length)
echo "Number of Monitors: $numberOfMonitors"

# TODO, avoid temporary file
dwm-msg get_monitors > /tmp/mons.json
mons=$(jq '.[].num' /tmp/mons.json)

for monNum in ${mons[@]}; do
  echo $monNum
done

clientData=$(echo $(( $(wmctrl -l | grep $windowName | cut -d' ' -f1) )) | xargs dwm-msg get_dwm_client)
echo $clientData

tagNum=$(echo $clientData | jq '.tags')
echo "tagNum: $tagNum"

monNum=$(echo $clientData | jq '.monitor_number')
echo "MonNum: $monNum"

$(dwm-msg run_command focusmon $monNum)
$(dwm-msg run_command view $tagNum)

