#!/bin/bash

echo -n  %{F#888}󰞄%{F-}$(df -h / --output=pcent | sed 1d | tr -d ' ') 

