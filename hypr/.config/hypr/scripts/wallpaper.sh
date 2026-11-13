#!/bin/bash
# Wallpapers via awww (swww fork; independent of hyprlang, reliable on NVIDIA).

# Start the awww daemon if it isn't running yet
if ! awww query >/dev/null 2>&1; then
    awww-daemon &
    # wait for the daemon to be ready
    for _ in $(seq 1 20); do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi

# Per-monitor wallpapers
awww img "$HOME/Pictures/wallpapers/lg.png"   --outputs HDMI-A-1
awww img "$HOME/Pictures/wallpapers/asus.png" --outputs DP-3
