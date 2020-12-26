#!/bin/bash

rm -rf /tmp/polybar_mqueue.* && echo ">> Removed mqueue" | tee -a /tmp/polybar-all.log
killall -q polybar && echo ">> Killed All Bars" | tee -a /tmp/polybar-all.log

bars=(main1 main2 main3 left right)
for bar in ${bars[@]}; do
  
  echo "==> Launching $bar" | tee -a /tmp/polybar-$bar.log
  $(polybar --reload $bar | tee -a /tmp/polybar-$bar.log) & disown
done

# polybar --reload main2 >>/tmp/polybar-all.log 2>&1 &
# polybar --reload main3 >>/tmp/polybar-all.log 2>&1 &
# polybar --reload left  >>/tmp/polybar-all.log 2>&1 &
# polybar --reload right >>/tmp/polybar-all.log 2>&1 &
