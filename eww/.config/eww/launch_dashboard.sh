#!/bin/bash

# Get cursor position to determine monitor
POS=$(hyprctl cursorpos)
X=${POS%%,*}

# Hyprctl IDs: DP-3 (ID 1) is Left (< 1920), HDMI-A-1 (ID 0) is Right (>= 1920)
if [ "$X" -lt 1920 ]; then
    TARGET_SCREEN=1
else
    TARGET_SCREEN=0
fi

if [[ -z $(eww active-windows | grep 'dashboard') ]]; then
    eww update dashboard_reveal=false
    eww open dashboard --id dashboard --screen $TARGET_SCREEN
    # Wait for window to be created
    while [[ -z $(eww active-windows | grep 'dashboard') ]]; do sleep 0.05; done
    eww update dashboard_reveal=true
else
    eww update dashboard_reveal=false
    (sleep 0.4 && eww close dashboard) &
fi
