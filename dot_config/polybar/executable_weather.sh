#!/bin/sh

get_icon() {
    case $1 in
        # Icons for weather-icons
        01d) icon="󰖙";;
        01n) icon="󰖔";;
        02d) icon="󰖕";;
        02n) icon="󰼱";;
        03*) icon="󰖐";;
        04*) icon="󰖐";;
        09*) icon="󰼳";;
        #09n) icon="";;
        10*) icon="󰖖";;
        11*) icon="󰙾";;
        13*) icon="󰼶";;
        50*) icon="󰖑";;
        *) icon="";
    esac

    echo $icon
}

get_duration() {

    osname=$(uname -s)

    case $osname in
        *BSD) date -r "$1" -u +%H:%M;;
        *) date --date="@$1" -u +%H:%M;;
    esac

}

KEY="db81756d9a36342a14818445353dff32"
CITY="Birmingham, GB"
UNITS="metric"
SYMBOL="°C"

API="https://api.openweathermap.org/data/2.5"

if [ -n "$CITY" ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
    forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ -n "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        current=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
        forecast=$(curl -sf "$API/forecast?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS&cnt=1")
    fi
fi

if [ -n "$current" ] && [ -n "$forecast" ]; then
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(echo "$current" | jq -r ".weather[0].icon")

    forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
    forecast_icon=$(echo "$forecast" | jq -r ".list[].weather[0].icon")

    if [ "$current_temp" -gt "$forecast_temp" ]; then
        trend="󰜮"
    elif [ "$forecast_temp" -gt "$current_temp" ]; then
        trend="󰜷"
    else
        trend="󰜴"
    fi


    sun_rise=$(echo "$current" | jq ".sys.sunrise")
    sun_set=$(echo "$current" | jq ".sys.sunset")
    now=$(date +%s)
    
    if [ "$sun_rise" -gt "$now" ]; then
        daytime="󰖜$(date --date="@$sun_rise" -u +%H:%M)"
    elif [ "$sun_set" -gt "$now" ]; then
        daytime="󰖛$(date --date="@$sun_set" -u +%H:%M)"
    else
        daytime="󰖜$(date --date="@$sun_rise" -u +%H:%M)"
    fi

    echo "  %{F#888}$(get_icon "$current_icon")%{F-}$current_temp$SYMBOL > %{F#888}$(get_icon "$forecast_icon")%{F-}$forecast_temp$SYMBOL %{F#888}$daytime"
fi
