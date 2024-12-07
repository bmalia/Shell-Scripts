#!/bin/bash

echo "Checking for package updates..."
sleep .5
echo "Syncing offical repos..."
updatestatus="$(checkupdates 2>&1)"
cuexit=$?
sleep 1
if [ $cuexit -eq 127 ]; then
    echo "Error: pacman-contrib not installed"
    sleep .5
    echo "Attempting installation..."
    sudo pacman -S pacman-contrib
    echo "Done!"
    sleep .5
    echo "Retrying checkupdates..."
    checkupdates
elif [[ $cuexit -eq 2 ]]; then
    echo "Official packages up to date"
    echo "Proceeding..."
elif [[ $cuexit -eq 0 ]]; then
    packagecount=$(echo "$updatestatus" | wc -l)
    echo "$packagecount packages out of date"
    echo "Proceeding..."
elif [[ $cuexit -eq 1 ]]; then
    echo "Unrecoverable error: $updatestatus"
    exit 1
fi

sleep 1
echo "Checking AUR updates..."
tempfile=$(mktemp)
yay -Qu --color never > "$tempfile" 2>&1
aurexit=$?

aurstatus=$(cat "$tempfile" | sed 's/Get .*//')
rm "$tempfile"

echo $aurexit
echo "$aurstatus"