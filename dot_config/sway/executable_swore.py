#!/usr/bin/python
import sys
from subprocess import check_output
from time import sleep
from systemd import journal

orientation = last = None

xf=open('/sys/bus/iio/devices/iio:device0/in_accel_x_raw')
yf=open('/sys/bus/iio/devices/iio:device0/in_accel_y_raw')

j = journal.Reader()
j.this_boot()
j.log_level(journal.LOG_INFO)
j.add_match("SYSLOG_IDENTIFIER=kernel")

def rotate(o):
    check_output('swaymsg output eDP-1 transform ' + ['normal', '270', '180', '90'][o], shell=True)
    check_output('pkill -SIGUSR' + ['1', '2', '1', '2'][o] + ' wvkbd-mobintl', shell=True)

while True:
    xf.seek(0)
    yf.seek(0)
    x = int(xf.readline())
    y = int(yf.readline())

    o = 2 * (y-x > 0) + (abs(x) > abs(y))

    if o != orientation and (o == last or len(sys.argv)) and max(abs(x), abs(y)) > 900000:
        for m in j:
            if "Yoga usage mode changed to" in m['MESSAGE']:
                mode = m['MESSAGE'].split()[-1]
        if mode == "laptop":
            print('laptop')
            rotate(0)
        else:
            print(['normal', 'left', 'inverted', 'right'][o], flush=True)
            rotate(o)
        orientation = o
    last = o
    if len(sys.argv) > 1:
        break
    sleep(1)

xf.close()
yf.close()

exit(o)
