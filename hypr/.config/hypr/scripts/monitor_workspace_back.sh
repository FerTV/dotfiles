#!/bin/bash

# Usage: monitor_workspace.sh <workspace_index_1-5> [move]
# If second argument is "move", moves the active window to the target workspace.

# Get the target index (1-5)
INDEX=$1
ACTION=$2

# Get active monitor name using hyprctl
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Determine target workspace ID based on monitor
# Left Monitor (DP-3) -> IDs 1-5
# Right Monitor (HDMI-A-1) -> IDs 6-10

if [[ "$MONITOR" == "HDMI-A-1" ]]; then
    # On Right Monitor, map 1->6, 2->7, etc.
    TARGET_WORKSPACE=$((INDEX + 5))
else
    # On Left Monitor (or others), keep 1->1
    TARGET_WORKSPACE=$INDEX
fi

if [[ "$ACTION" == "move" ]]; then
    hyprctl dispatch movetoworkspace $TARGET_WORKSPACE
else
    hyprctl dispatch workspace $TARGET_WORKSPACE
fi
