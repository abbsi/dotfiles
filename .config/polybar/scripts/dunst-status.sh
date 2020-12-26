#!/bin/bash

# Could us this script to output icon in a single poly bar module
# this can work as a single status monitor sciprt for multiple modules

bar1=$(pgrep -f "polybar --reload main1")

if [ "$(dunstctl is-paused)" = "false" ]; then
  polybar-msg -p "$bar1" hook dunst-status 1 1>/dev/null 2>&1
elif [ "$(dunstctl is-paused)" = "true" ]; then
  polybar-msg -p "$bar1" hook dunst-status 2 1>/dev/null 2>&1
else 
  polybar-msg -p "$bar1" hook dunst-status 3 1>/dev/null 2>&1
fi