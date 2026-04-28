#!/bin/bash

# Rofi config
# Start with a notification
notify-send "Getting list of available Wi-Fi networks..."

# Get a list of available wifi connections and morph it into a nice-looking list
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.*/🔒/g" | sed "s/^--/🔓/g" | sed "s/🔒  /🔒 /g" | sed "s/🔓  /🔓 /g" | sort -u)

chosen_network=$(echo -e "$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )

# Get name of connection
read -r chosen_id <<< "${chosen_network:3}"

if [ "$chosen_network" = "" ]; then
	exit
fi

# Message
message="You are now connected to the Wi-Fi network \"$chosen_id\"."

# Get saved connections
saved_connections=$(nmcli -g NAME connection)

if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
	nmcli device wifi connect "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$message"
else
	if [[ "$chosen_network" =~ "🔒" ]]; then
		wifi_password=$(rofi -dmenu -p "Password: " )
	fi
	nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$message"
fi
