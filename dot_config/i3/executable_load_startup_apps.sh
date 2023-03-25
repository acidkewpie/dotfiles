#!/bin/bash
xsetwacom --set "Wacom HID 52CD Finger touch" MaptoOutput eDP-1
gnome-keyring-daemon --start --components=ssh,secrets,pkcs11
i3-msg workspace 2:
sleep 2
alacritty &
alacritty &
sleep 10
i3-msg workspace 1:
google-chrome --password-store=gnome &

