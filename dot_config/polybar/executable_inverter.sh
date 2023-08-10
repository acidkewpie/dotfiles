#!/bin/bash
API="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NTc3MDIxOS1jYWE2LTRmOTctOTE3Ni0zNDBlZGMzZDQxNTgiLCJqdGkiOiJmNGFlYTViMzI3Mzg0OGNlNjBiMThlM2Q0ZjA4NzMwNWYzMDNiOWU0ZTY2YjU1ZmE2YmI0YTMxYzEwMjJjMzVkMjQ3MGYzZWQ3OWU3NWZmYyIsImlhdCI6MTY5MTY1ODU3My4zMDc2ODIsIm5iZiI6MTY5MTY1ODU3My4zMDc2ODUsImV4cCI6MTcyMzI4MDk3My4yOTg3NjksInN1YiI6IjEwNzM5Iiwic2NvcGVzIjpbImFwaSJdfQ.OZ0CZM-LMBckZVknAZMjj08Wa-BjUqBNn14IB4Cy4zBXp8_nV39iGTgv4yTRHT_StY9j1R2EZGeL6Je2CvaWLA"

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

