#!/bin/bash

sleep 2 # Give polybar a chance to start up. Keeps exiting without this.

# see man zscroll for documentation of the following parameters
zscroll -l 40 \
        --delay 0.75 \
        --match-command "$HOME/.config/polybar/scripts/playerctl-wrapper.sh" \
        --match-text "Playing" "--before-text '  ' --scroll 1" \
        --match-text "Paused" "--before-text '  ' --scroll 0" \
        --match-text "NoPlayer" "--scroll 0" \
        --update-check true "$HOME/.config/polybar/scripts/player_get_status.sh" &
wait