#!/bin/sh

# Terminate already running bar instances
# killall -q polybar

# Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
#MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)

#MONITORS=$MONITORS polybar default &
#MONITOR=$MONITORS polybar default;

#polybar default

touch ~/.config/polybar/config.ini
for m in $(polybar -m | cut -d: -f1); do
  pgrep -f "polybar --reload $m -l error" || polybar --reload $m -l error&
done

echo "Bars launched..."

