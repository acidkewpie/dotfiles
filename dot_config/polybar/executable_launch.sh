#!/bin/sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
#MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

#MONITORS=$MONITORS polybar default &
#MONITOR=$MONITORS polybar default;

#polybar default


if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload default &
  done
else
  polybar --reload default &
fi


echo "Bars launched..."

