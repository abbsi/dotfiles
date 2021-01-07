#!/bin/bash
playerctl --player=playerctld status 2> /dev/null 1> /dev/null

if [ $? -eq 0 ]
then
  echo $(playerctl --player=playerctld status)
else
  echo "NoPlayer"
fi

