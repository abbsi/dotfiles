#!/bin/bash

sleep 5 # Give polybar a chance to start up. Keeps exiting without this.

# see man zscroll for documentation of the following parameters
zscroll -l 55 \
        --delay 0.75 \
        --match-command "$HOME/.config/polybar/scripts/playerctl-wrapper.sh" \
        --match-text "Playing" "--before-text '  ' --scroll 1" \
        --match-text "Paused" "--before-text '  ' --scroll 0" \
        --match-text "No Player" "--scroll 0" \
        --update-check true "$HOME/.config/polybar/scripts/get_spotify_status.sh" &

wait