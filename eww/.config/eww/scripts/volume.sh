#!/bin/bash

# Configuration
SOUND_FILE="/home/w1nt3r/.local/share/Steam/friends/message.wav"

# Function to play sound
play_sound() {
    if [ -f "$SOUND_FILE" ]; then
        paplay "$SOUND_FILE" &
    fi
}

# Function to show notification
show_notification() {
    # Get current volume
    VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
    
    # Determine icon based on volume
    if [ "$VOLUME" -eq 0 ]; then
        ICON="audio-volume-muted"
    elif [ "$VOLUME" -lt 30 ]; then
        ICON="audio-volume-low"
    elif [ "$VOLUME" -lt 70 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi

    # Check for mute state
    IS_MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep "MUTED")
    if [ -n "$IS_MUTED" ]; then
        ICON="audio-volume-muted"
        msg="Muted"
    else
        msg="${VOLUME}%"
    fi

    # Send notification
    # -h string:x-canonical-private-synchronous:volume ensures it replaces the previous notification
    # -h int:value:$VOLUME displays the progress bar
    # -t 2000 sets a 2-second timeout
    notify-send -u low -t 2000 \
        -h string:x-canonical-private-synchronous:volume \
        -h int:value:"$VOLUME" \
        -i "$ICON" \
        "Volume" "$msg"
}

# Handle arguments
case "$1" in
    set)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$2"%
        
        # Debounce sound (play at most every 150ms)
        NOW=$(date +%s%3N)
        LAST_RUN_FILE="/tmp/volume_sound_debounce"
        if [ -f "$LAST_RUN_FILE" ]; then
            LAST_RUN=$(cat "$LAST_RUN_FILE")
        else
            LAST_RUN=0
        fi
        
        DIFF=$((NOW - LAST_RUN))
        if [ "$DIFF" -gt 150 ]; then
            play_sound
            echo "$NOW" > "$LAST_RUN_FILE"
        fi
        ;;
    up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        play_sound
        show_notification
        ;;
    down)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
        play_sound
        show_notification
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        show_notification
        ;;
esac
