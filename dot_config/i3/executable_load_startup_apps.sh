#!/bin/bash
onboard &
xsetwacom --set "Wacom HID 52CD Finger touch" MaptoOutput eDP-1
gnome-keyring-daemon --start --components=ssh,secrets,pkcs11
i3-msg workspace 2:
sleep 1
alacritty &
alacritty &
sleep 5
i3-msg workspace 1:
google-chrome --password-store=gnome &

