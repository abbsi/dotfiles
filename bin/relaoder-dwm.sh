#!/bin/bash
# relaunch DWM if the binary changes, otherwise bail
csum=""
new_csum=$(sha1sum $(which dwm))
while true
do
  echo $csum >> /tmp/dwm-reloader
  if [ "$csum" != "$new_csum" ]
  then
     csum=$new_csum
     dwm
  else
     exit 0
  fi
  new_csum=$(sha1sum $(which dwm))
  sleep 0.5
done
