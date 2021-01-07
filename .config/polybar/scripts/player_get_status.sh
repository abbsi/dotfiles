#!/bin/bash

bars=$(pgrep -f '^polybar')
status=$("$HOME"/.config/polybar/scripts/playerctl-wrapper.sh)

for bar in ${bars[@]}; do
  case $status in
    NoPlayer)
      echo " "
      ;;
    Stopped)
      echo " "
      ;;
    Paused)
      polybar-msg -p "$bar" hook player-play-pause 2 1>/dev/null 2>&1
      playerctl --player=playerctld metadata --format "{{ artist }}"
      ;;
    *)
      polybar-msg -p "$bar" hook player-play-pause 1 1>/dev/null 2>&1
      playerctl --player=playerctld metadata --format "{{ artist }} - {{title}}"
      ;;
  esac
done