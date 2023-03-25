#!/bin/sh

MONS=$(polybar -m | wc -l)
BARS=$(pgrep -c polybar)
if [ "$MONS" -eq "$BARS" ]
then
  touch ~/.config/polybar/config.ini
elif [ "$MONS" -eq "1" ]
then
  pkill polybar
  polybar --reload default &
else
  pkill polybar
  for m in $(polybar -m | cut -d: -f1); do
    pgrep -f "polybar --reload $m" || polybar --reload $m &
  done
fi

echo "Bars launched..."

