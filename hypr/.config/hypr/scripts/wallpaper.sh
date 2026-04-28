#!/bin/bash

# Kill old instances
pkill hyprpaper
sleep 0.1

# Start hyprpaper with explicit config
hyprpaper --config ~/.config/hypr/hyprpaper.conf &

# Fallback: Wait a tiny bit and force reload if it failed to pick up
sleep 0.5
if pgrep hyprpaper > /dev/null; then
    # Force apply just in case
    hyprctl hyprpaper wallpaper "HDMI-A-1,/home/w1nt3r/Pictures/wallpapers/lg.png"
    hyprctl hyprpaper wallpaper "DP-3,/home/w1nt3r/Pictures/wallpapers/asus.png"
fi
