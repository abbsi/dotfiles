#!/usr/bin/env bash
# Requires 'entr'
# Run this script while in the Rofi direcotry using this command: /bin/ls | entr -r ./run_rofi.sh
# Script will open rofi if a file is modified/saved

options="one
two
three"
theme=${1:-$HOME/.config/rofi/config.rasi}
selection=$(echo -e "${options}" | rofi -dmenu -config $theme)
case "${selection}" in
  "one")
    notify-send "run_rofi.sh" "one";;
  "two")
    notify-send "run_rofi.sh" "two";;
  "three")
    notify-send "run_rofi.sh" "three";;
esac
