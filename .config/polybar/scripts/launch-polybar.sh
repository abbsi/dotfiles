#!/bin/bash

# Export network interface with Internet
export INET_IFACE=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
echo ">> Interface Name: $INET_IFACE" | tee -a /tmp/polybar-all.log

# Export path to AMD Tctl for temperature module
for path in /sys/class/hwmon/hwmon*/temp*_label; do
    label="$(cat "$path")"

    if [[ "$label" == "Tctl" ]]; then
        export HWMON_PATH="${path%_label}_input"
        echo ">> HWMON Path: $HWMON_PATH" | tee -a /tmp/polybar-all.log
    fi
done

# Remove old IPC
rm -rf /tmp/polybar_mqueue.* && echo ">> Removed mqueue" | tee -a /tmp/polybar-all.log

# Kill bars
killall -q polybar && echo ">> Killed All Bars" | tee -a /tmp/polybar-all.log

# Load array of bars
bars=(main left right)
for bar in ${bars[@]}; do
  echo "==> Launching $bar" | tee -a /tmp/polybar-$bar.log
  $(polybar --log=warning --reload $bar | tee -a /tmp/polybar-$bar.log) &
done
