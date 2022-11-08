#!/bin/bash

a=1
for f in ~/.wallpapers/*; do 
  echo "Processing $f file.."
  wal -i $f --backend schemer2
  sleep 2
  rofi-app &
  sleep 2
  padded=$(printf "%04d" "$a")
  $(scrot -a 0,80,2560,1440 /home/abbsi/.wallpapers/screens/$padded-%Y%m%d-%s.png)
  sleep 2
  xdotool key Escape
  let a=a+1
done
 