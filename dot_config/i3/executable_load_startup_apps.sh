#!/bin/bash

gnome-keyring-daemon --start --components=ssh,secrets,pkcs11
i3-msg workspace 2:
sleep 2
gnome-terminal &
gnome-terminal &
sleep 10
i3-msg workspace 1:
google-chrome --password-store=gnome &

