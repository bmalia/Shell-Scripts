#!/bin/bash

echo "Welcome to my archinstall script"
echo "This was mainly written for me to learn how the install process works. Please do not use this expecting it to work."
sleep 1
echo -n "Checking for internet..."
ping -c 3 google.com > /dev/null 2>&1
instatus=$?
if [[ $instatus -eq 2 ]]; then
    echo " Failed!"
    sleep .5
    echo "Error: No internet access. Please check your internet connection and try again"
    echo "To connect to wifi, use the iwctl command"
    exit 1
else
    echo " Done!"
    echo "Connection verified. Launching installer..."
    sleep 1
    clear
fi
echo "Would you like to generate a new mirrorlist?"
echo "[Y]es [N]o"
read -r confirm
while [[ "$confirm" != "y" && "$confirm" != "n" ]]; do
  read -r -p "Invalid input. Please enter y or n: " confirm
done

if [[ "$confirm" == "y" ]]; then
  echo -n "Generating country list..."
  countrylist="$(reflector --list-countries 2>&1)"
  echo " Done!"
  sleep 1
  echo "$countrylist"
  echo "Mirrorlist setting coming soon. Please run 'reflector' to generate a custom mirrorlist"
else
  echo "Proceeding without a custom mirrorlist"
  exit
fi
sleep 1
echo "2: Disk configuration"
sleep .5
echo "Please select an option"
echo "[P]re-mounted config [A]uto partition layout (coming soon) [L]VM (coming soon)"
read -r diskmode
while [[ "$diskmode" != "y" && "$diskmode" != "n" ]]; do
  read -r -p "Invalid input. Please enter one of the prefixes shown above: " diskmode
done

if [[ "$diskmode" == "p" ]]; then
