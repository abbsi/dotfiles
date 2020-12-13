#!/bin/bash

status=$("$HOME"/.config/polybar/scripts/playerctl-wrapper)

if [ "$status" = "No Player" ]; then
    echo "..  .."
elif [ "status" = "Stopped" ]; then
    echo "..  .."
elif [ "$status" = "Paused"  ]; then
    polybar-msg -p "$(pgrep -f "polybar --reload main")" hook spotify-play-pause 2 1>/dev/null 2>&1
    playerctl --player=playerctld metadata --format "{{ artist }}"
else # Can be configured to output differently when player is paused
    polybar-msg -p "$(pgrep -f "polybar --reload main")" hook spotify-play-pause 1 1>/dev/null 2>&1
    playerctl --player=playerctld metadata --format "{{ artist }} - {{ title }}"
fi