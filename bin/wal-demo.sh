#!/bin/bash

for f in ~/.wallpapers/*; do 
  echo "Processing $f file.."
  wal -i $f --backend schemer2
  sleep 2
  rofi-app &
  sleep 2
  xdotool key Escape
done