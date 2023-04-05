#!/usr/bin/python
from subprocess import run
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

    if mouse is not keyboard:
        timeout, color = 5, '%{F#F00}'
        run(['/usr/bin/aplay', '/etc/sounds/honk.wav', '-q'])
    else:
        timeout, color = 300, ''

    print(  '' if mouse else color + '', 
            '' if keyboard else color + '', 
            sep='%{F-}', flush=True)

    for device in iter(partial(monitor.poll, timeout), None):
        print(device.get('HID_NAME'))
        if 'K850' in device.get('HID_NAME') and device.action == 'add':
            keyboard = True
        if 'K850' in device.get('HID_NAME') and device.action == 'remove':
            keyboard = False
        if 'M720' in device.get('HID_NAME') and device.action == 'add':
            mouse = True
        if 'M720' in device.get('HID_NAME') and device.action == 'remove':
            mouse = False
        break

