#!/usr/bin/python
from subprocess import run
from os import environ
import evdev

device_name, _s = 'SayoDevice SayoDevice 2x3F', 0

RED = '%{F' + (environ.get('RED') or '#F00') + '}'
YELLOW = '%{F' + (environ.get('YELLOW') or '#0F0') + '}'
HIGHLIGHT = '%{F' + (environ.get('HIGHLIGHT') or '#00F') + '}'

def set_source(s):
    global _s 
    source = {'DP': '15', 'HDMI': '17'}
    print(YELLOW if s == 'HDMI' else HIGHLIGHT, "", sep='', flush=True)
    if _s != s:
        run(["/usr/bin/ddccontrol", "-r", "0x60", "-w", source[s], 
            "dev:/dev/i2c-15"], capture_output=True, timeout=10)
        _s = s

print(RED + '', flush=True)
for d in evdev.util.list_devices():
    device = evdev.InputDevice(d)
    if device_name == device.name:
        break

for event in device.read_loop():
    if event.type == evdev.ecodes.EV_KEY:
        if(event.code == 2 and event.value == 2 ):
            set_source("DP")
        if(event.code == 4 and event.value == 2 ):
            set_source("HDMI")
