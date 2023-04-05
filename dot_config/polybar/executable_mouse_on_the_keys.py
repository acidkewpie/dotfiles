#!/usr/bin/python
import subprocess
from pyudev import Context, Monitor
from functools import partial 

context = Context()
monitor = Monitor.from_netlink(context)
monitor.filter_by('hid')

for device in context.list_devices(subsystem='hid'):
    if 'K850' in device.get('HID_NAME'):
        keyboard = True
    if 'M720' in device.get('HID_NAME'):
        mouse = True 

while True:

    print("" if mouse else "%{F#F00}", "" if keyboard else "%{F#F00}", sep='%{F-}', flush=True)
    timeout = 300
    if mouse is not keyboard:
        timeout = 5
        subprocess.run(["/usr/bin/aplay", "/etc/sounds/honk.wav", "-q"])

    for device in iter(partial(monitor.poll, timeout), None):
        if 'K850' in device.get('HID_NAME') and device.action == 'add':
            keyboard = True
        if 'K850' in device.get('HID_NAME') and device.action == 'remove':
            keyboard = False
        if 'M720' in device.get('HID_NAME') and device.action == 'add':
            mouse = True
        if 'M720' in device.get('HID_NAME') and device.action == 'remove':
            mouse = False
        break

