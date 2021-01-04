#!/usr/bin/env bash

picom &
nitrogen --restore &
numlockx &
wal -R
# mpd-mpris -port 6601 &
# ympd --p 6601 -w 8080 &

# https://github.com/jD91mZM2/xidlehook
brgt1="--brightness .6"
brgt2="--brightness .4"
brgt3="--brightness .2"
brgtF="--brightness  1"

monLt="--output DP-2"
monCt="--output HDMI-0"
monRt="--output DP-0"

xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 300 \
    "xrandr $monLt $brgt1 $monCt $brgt1 $monRt $brgt1" \
    "xrandr $monLt $brgtF $monCt $brgtF $monRt $brgtF" \
  --timer 60 \
    "xrandr $monLt $brgt2 $monCt $brgt2 $monRt $brgt2" \
    "xrandr $monLt $brgtF $monCt $brgtF $monRt $brgtF" \
  --timer 30 \
    "xrandr $monLt $brgt3 $monCt $brgt3 $monRt $brgt3" \
    "xrandr $monLt $brgtF $monCt $brgtF $monRt $brgtF" \
  --timer 15 \
    "slock" \
    "xrandr $monLt $brgtF $monCt $brgtF $monRt $brgtF" &
    
dunstify -u low "Completed Autostart.sh" &

## Alterntive Options for status bars or auto locking
# slstatus &
# dwmblocks &
# xautolock -time 5 -locker "slock" -detectsleep &