#!/bin/bash

echo "Welcome to my archinstall script"
echo "This was mainly written for me to learn how the install process works. Please do not use this expecting it to work."
sleep 1
echo "Checking for internet..."
ping -c 3 google.com
instatus=$?
if [[ $instatus -eq 1]]; then
    echo "Error: No internet access. Please check your internet connection and try again"
    echo "To connect to wifi, use the iwctl command"
    exit 1
fi
echo "Connection verified. Launching installer..."
sleep 1
clear
