#!/bin/bash
API="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NTc3MDIxOS1jYWE2LTRmOTctOTE3Ni0zNDBlZGMzZDQxNTgiLCJqdGkiOiIyNTM0MzI2MDU5ZGM1ZjFmOTE2Mjk2ZjhkMWZkMmE0MjQxMDc1ZTUwMTIyOTI5NTg4OTc4N2Q1OWM2N2QwZGZkMWFkOWE3ZTFhMTAwMDdmZiIsImlhdCI6MTY1ODk5NjAxMy4zODU3MzIsIm5iZiI6MTY1ODk5NjAxMy4zODU3MzUsImV4cCI6MTY5MDUzMjAxMy4zODA1ODEsInN1YiI6IjEwNzM5Iiwic2NvcGVzIjpbImFwaSJdfQ.yHPuXTwtHSfQCFv4NoFIbaJddW7M-9-8RBL-9FCAFX2XYeSgf72OAzPCU8FiTjDqj4CHyYBJW2H1SNvX9oLTug"

JSON=$(curl -svk https://api.givenergy.cloud/v1/inverter/CE2209G205/system-data/latest -H "Authorization: Bearer $API" -H "Accept: application/json" -H "Content-Type: application/json" 2>/dev/null)

BATTERY=$(echo $JSON | jq '.data.battery.power')
BATTPER=$(echo $JSON | jq '.data.battery.percent')
SOLAR=$(echo $JSON | jq '.data.solar.power')
GRID=$(echo $JSON | jq '.data.grid.power')
USE=$(echo $JSON | jq '.data.consumption')

if [ $BATTERY -ge 0 ]
then
  BATTICONS="󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹󰁹"
else
  BATTERY=$(bc <<< "scale=1; $BATTERY * -1")
  BATTICONS="󰢟󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂋󰂅"
fi

BATTKW=$(printf '%.1f' $(bc <<< "scale=1; $BATTERY / 1000"))
SOLARKW=$(printf '%.1f' $(bc <<< "scale=1; $SOLAR / 1000"))
GRIDKW=$(printf '%.1f' $(bc <<< "scale=1; $GRID / 1000"))
USEKW=$(printf '%.1f' $(bc <<< "scale=1; $USE / 1000"))

BATTPOS=${BATTPER::-1} # remove last digit
BATTICON=${BATTICONS:BATTPOS:1}

if [ "$1" == "x" ]
then
  echo $JSON | jq
fi
echo "%{F#888}󰟨%{F-}$USEKW %{F#888}󰶛%{F-}$SOLARKW %{F#888}$BATTICON%{F-}$BATTKW $BATTPER% %{F#888}󰋁%{F-}$GRIDKW"

