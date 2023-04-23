#!/usr/bin/python
from subprocess import run
from pyudev import Context, Monitor
from functools import partial
from os import environ

RED = '%{F' + (environ.get('RED') or '#F00') + '}'
YELLOW = '%{F' + (environ.get('YELLOW') or '#0F0') + '}'
ORANGE = '%{F' + (environ.get('ORANGE') or '#FF0') + '}'
HIGHLIGHT = '%{F' + (environ.get('HIGHLIGHT') or '#00F') + '}'

context = Context()
monitor = Monitor.from_netlink(context)
monitor.filter_by('hid')

detected=False
detect = run(["/usr/bin/ddcutil", "detect", "--sleep-multiplier", ".5"], capture_output=True).stdout
for line in detect.decode('utf8').split('\n'):
    if 'I2C bus' in line: 
        i2c = line.split('-')[1].strip()
    if '1179911201181' in line: 
        detected=True
        break
run(["/usr/bin/logger", "i2c-device-for-ddcutil-is", i2c])

def set_source(s):
    if detected:
        if s not in run(["/usr/bin/ddcutil", "getvcp", "0x60", "--sleep-multiplier", ".2", "--bus", i2c], capture_output=True).stdout.decode('utf8'):
            run(["/usr/bin/ddcutil", "setvcp", "0x60", {'DisplayPort':'15','HDMI':'17'}[s], "--sleep-multiplier", ".2", "--bus", i2c], 
                capture_output=True, timeout=10)
        return(YELLOW if s == 'HDMI' else HIGHLIGHT)
    return(RED)

def get_hids():
    devices=[d.get('HID_NAME') for d in context.list_devices(subsystem='hid')]
    k = True if 'Keyboard K850' in devices else False
    m = True if 'M720 Triathlon' in devices else False
    u = True if 'Logitech USB Receiver' in devices else False
    return (m, k, u)

source=ORANGE
while True:
    (mouse, keyboard, usb) = get_hids()
    timeout = 300
    if usb:
        print(ORANGE + '',end='')
    elif mouse is not keyboard:
        timeout = 5
        run(['/usr/bin/aplay', '/etc/sounds/honk.wav', '-q'])
        print(HIGHLIGHT + '' + RED + '' if mouse else RED + '' + HIGHLIGHT + '',end='')
    elif mouse and keyboard:
        source=set_source('DisplayPort')
        print(HIGHLIGHT + '',end='')
    else: 
        source=set_source('HDMI')
        print(YELLOW + '',end='')
    print(source +'', flush=True)
    for device in iter(partial(monitor.poll, timeout), None):
        break

