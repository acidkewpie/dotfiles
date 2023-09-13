#!/usr/bin/python
import subprocess
import sys
import os
import time
from pyudev import Context, Monitor
from functools import partial

RED = '%{F' + (os.environ.get('RED') or '#F00') + '}'
YELLOW = '%{F' + (os.environ.get('YELLOW') or '#0F0') + '}'
ORANGE = '%{F' + (os.environ.get('ORANGE') or '#FF0') + '}'
HIGHLIGHT = '%{F' + (os.environ.get('HIGHLIGHT') or '#00F') + '}'

context = Context()
monitor = Monitor.from_netlink(context)
monitor.filter_by('hid')

i2c='MISSING'
detect = subprocess.Popen(["/usr/bin/ddcutil", "detect", "--sleep-multiplier", ".5"], stdout=subprocess.PIPE)
for line in iter(detect.stdout.readline, b''):
    subprocess.run(["/usr/bin/logger", line.decode('utf8')])
    if 'I2C bus' in line.decode('utf8'): 
        _i2c = line.decode('utf8').split('-')[1].strip()
    if '1179911201181' in line.decode('utf8'): 
        i2c = _i2c
        break

subprocess.run(["/usr/bin/logger", "i2c-device-for-ddcutil-is", i2c])
print("i2c-device-for-ddcutil-is", i2c)
if i2c == 'MISSING':
    time.sleep(10)
    sys.exit()

def set_source(s):
    ddcutil=subprocess.run(["/usr/bin/ddcutil", "getvcp", "0x60", "--sleep-multiplier", ".2", "--bus", i2c], capture_output=True)
    #if s not in ddcutil.stdout.decode('utf8'):
    #    ddcutil = subprocess.run(["/usr/bin/ddcutil", "setvcp", "0x60", {'DisplayPort':'15','HDMI':'17'}[s], \
    #            "--sleep-multiplier", ".2", "--bus", i2c], capture_output=True, timeout=10)
    return(YELLOW if s == 'HDMI' else HIGHLIGHT)

def get_hids():
    devices=[d.get('HID_NAME') for d in context.list_devices(subsystem='hid')]
    k = True if 'Keyboard K850' in devices else False # directly connected only
    m = True if 'M720 Triathlon' in devices else False # directly connected only
    u = True if 'Logitech USB Receiver' in devices else False
    return (m, k, u)

source=ORANGE
while True:
    timeout = 300
    (mouse, keyboard, usb) = get_hids()

    if usb:
        source=set_source('DisplayPort')
        if mouse is not keyboard:
            timeout = 5
            subprocess.run(['/usr/bin/aplay', '/etc/sounds/honk.wav', '-q'])
            print(HIGHLIGHT + '' + RED + '' if mouse else RED + '' + HIGHLIGHT + '', end='')
        elif mouse and keyboard:
            print(HIGHLIGHT + '',end='')
        else: 
            print(YELLOW + '',end='')
        
    elif not usb:
        source=set_source('HDMI')
        if mouse is not keyboard:
            timeout = 5
            subprocess.run(['/usr/bin/aplay', '/etc/sounds/honk.wav', '-q'])
            print(HIGHLIGHT + '' + RED + '' if mouse else RED + '' + HIGHLIGHT + '', end='')
        elif mouse and keyboard:
            print(HIGHLIGHT + '',end='')
        else: 
            print(YELLOW + '',end='')

    print(source +'', flush=True)
    for device in iter(partial(monitor.poll, timeout), None):
        break

