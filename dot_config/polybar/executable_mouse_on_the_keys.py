#!/usr/bin/python
from subprocess import run
from pyudev import Context, Monitor
from functools import partial
from os import environ

RED = '%{F' + (environ.get('RED') or '#F00') + '}'
GREEN = '%{F' + (environ.get('GREEN') or '#0F0') + '}'
BLUE = '%{F' + (environ.get('BLUE') or '#00F') + '}'

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
        timeout, color = 5, RED
        run(['/usr/bin/aplay', '/etc/sounds/honk.wav', '-q'])
    elif mouse and keyboard:
        timeout, color = 300, GREEN
    else: 
        timeout, color = 300, BLUE

    print(  color + '' if mouse else color + '', 
            color + '' if keyboard else color + '', 
            sep='%{F-}', flush=True)

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

