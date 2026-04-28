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

if [[ -z $(eww active-windows | grep 'calendar') ]]; then
    eww open calendar --id calendar --screen $TARGET_SCREEN && eww update calrev=true
else
    eww update calrev=false
    # Wait slightly longer than the 300ms animation to ensure it finishes before closing
    (sleep 0.4 && eww close calendar) &
fi
