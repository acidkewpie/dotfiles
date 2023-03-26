#!/bin/sh -x

MONS=($(polybar -m | cut -d: -f1))
BARS=$(pgrep -c polybar)
if [ "${#MONS[@]}" -eq "$BARS" ]
then
  touch ~/.config/polybar/config.ini
else
  pkill polybar
  pidwait polybar
  if [ "${#MONS[@]}" -eq "1" ]
  then
    MONITOR=$MONS polybar --reload default &
  else
    for m in ${MONS[@]}; do
      polybar --reload $m &
    done
  fi
fi

echo "Bars launched..."

