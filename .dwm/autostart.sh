#!/usr/bin/env bash

## Start picom compositor. Current using ibhagwan's fork until it's merged into mainline (https://github.com/ibhagwan/picom)
picom &

## Enable below to restore wallpapers set by Nitrogen
# nitrogen --restore &

## Enables numlock on DWM start
numlockx &

## Calling `wal -R` directly from here was causing issues with Polybar. Calling the script below it instead with a 5 second delay
# wal -R &
restore-wal &

## If not using polybar, build one of the below options and enable
# slstatus &
# dwmblocks &

## Dims the screen after 5 minutes in 3 steps and then locks using slock
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
    
## Alterntive to above
# xautolock -time 5 -locker "slock" -detectsleep &

## If using MPD, install and enable below for polybar controls
# mpd-mpris -port 6601 &

## If using MPD, install and enable below for webcntrol of mpd
# ympd --p 6601 -w 8080 &

dunstify -u low "Completed Autostart.sh" &