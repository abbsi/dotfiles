#!/usr/bin/env bash

picom &
nitrogen --restore &
numlockx &
mpd-mpris -port 6601 &

# https://github.com/jD91mZM2/xidlehook
xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 300 \
    "xrandr --output DP-2 --brightness .8 --output HDMI-0 --brightness .8 --output DP-0 --brightness .8" \
    "xrandr --output DP-2 --brightness  1 --output HDMI-0 --brightness  1 --output DP-0 --brightness  1" \
  --timer 60 \
    "xrandr --output DP-2 --brightness .6 --output HDMI-0 --brightness .6 --output DP-0 --brightness .6" \
    "xrandr --output DP-2 --brightness  1 --output HDMI-0 --brightness  1 --output DP-0 --brightness  1" \
  --timer 30 \
    "xrandr --output DP-2 --brightness .4 --output HDMI-0 --brightness .4 --output DP-0 --brightness .4" \
    "xrandr --output DP-2 --brightness  1 --output HDMI-0 --brightness  1 --output DP-0 --brightness  1" \
  --timer 15 \
    "slock" \
    "xrandr --output DP-2 --brightness  1 --output HDMI-0 --brightness  1 --output DP-0 --brightness  1" &
    
dunstify -u low "Completed DWM Autostart.sh" &

## Alterntive Options for status bars or auto locking
# slstatus &
# dwmblocks &
# xautolock -time 5 -locker "slock" -detectsleep &