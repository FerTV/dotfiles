#!/bin/bash
# Wallpapers via swww (independent of hyprlang; reliable on NVIDIA).

# Start the swww daemon if it isn't running yet
if ! swww query >/dev/null 2>&1; then
    swww-daemon &
    # wait for the daemon to be ready
    for _ in $(seq 1 20); do
        swww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi

# Per-monitor wallpapers
swww img "$HOME/Pictures/wallpapers/lg.png"   --outputs HDMI-A-1
swww img "$HOME/Pictures/wallpapers/asus.png" --outputs DP-3
