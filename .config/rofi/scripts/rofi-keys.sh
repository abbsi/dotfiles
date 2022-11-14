#!/bin/bash
# List of DWM Keys


declare -a list=("--- DWM ---
Super+Shift      Q  quit
Super+Ctl+Shift  Q  Restart DWM
Super            Q  Kill Application
--- Launch ---
Super+Shift      Return  open terminal
Super            Space   Application
Super            X       Combi Run
Super            W       Windows
Super            E       File Browser
Super            P       dmenu
--- Screen Shots ---
                 Print  Area Select
C                Print  Full Screen
S                Print  Focuse Window
Super            Print  Screen Shot Menu
--- Layouts ---
Super           Return  Promote/Zoom to Master
Super+Shift     Space   toggle floating
Super           Tab     Cycle Layout
Super           - /+    N Master
Super           ﰲ / ﰯ   M Factor 
Super           ﰵ / ﰬ   Focus Client
Super+Shift     ﰵ / ﰬ   Rotate Stack
Super           C      Column 
Super           T 舘     Tile
Super           H ﳶ     Bottom Stack
Super           D      Dwindle
Super           M      Monocle
Super           F      Floating
Super           G      Grid
Super           S      Spiral
Super           U 充     Bottom Stack (Horizontal)
--- Monitors ---
Super          [  ]  Focus Monitor
Super+S        [  ]  Move to Monitor
--- Tags ---
Super           0      Select All Tags
Super+Shift     0      Tag to all
Super           N      Toggle Alt Tags
Super           R      Reorganize Tags
Super           U      Focus Urgent
Super           B      toggle bar
Super           grave  Scratch Pad
--- fzf.fish ---
Ctrl+Alt        F      Find File
Ctrl+Alt        S      git status
Ctrl+Alt        L      git log
Ctrl+R          R      Command History
Ctrl+V          V      Shell Variables
Ctrl+Alt        P      Processes")

$(echo -e "${list[@]}" | rofi -no-lazy-grab -dmenu -i -theme rofi-keys.rasi -p ' ')



