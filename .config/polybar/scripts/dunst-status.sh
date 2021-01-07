#!/bin/bash

# Could us this script to output icon in a single poly bar module
# this can work as a single status monitor sciprt for multiple modules

bars=$(pgrep -f '^polybar')
status=$(dunstctl is-paused)

for bar in ${bars[@]}; do
  case $status in
    false)
      polybar-msg -p "$bar" hook dunst-status 1 1>/dev/null 2>&1
      ;;
    true)
      polybar-msg -p "$bar" hook dunst-status 2 1>/dev/null 2>&1
      ;;
    *)  
      polybar-msg -p "$bar" hook dunst-status 3 1>/dev/null 2>&1
      ;;
  esac
done
