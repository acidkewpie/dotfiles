#!/usr/bin/python
import subprocess
import time
import pyudev
import evdev

mouse = False
keyboard = False
for d in evdev.util.list_devices():
    device = evdev.InputDevice(d)
    mouse = True if "M720" in device.name else mouse
    keyboard = True if "K850" in device.name else keyboard

if mouse is not keyboard:
    subprocess.run(["/usr/bin/aplay", "/etc/sounds/honk.wav", "-q"])

print("" if mouse else "%{F#F00}", "" if keyboard else "%{F#F00}", sep='%{F-}')
