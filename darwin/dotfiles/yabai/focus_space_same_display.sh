#!/bin/bash

direction=$1

display=$(yabai -m query --spaces --space | ~/.nix-profile/bin/jq '.display')
next_display=$(yabai -m query --spaces --space $direction | ~/.nix-profile/bin/jq '.display')

if [[ $display -eq $next_display ]]; then
  yabai -m space --focus $direction
fi
