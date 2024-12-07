#!/bin/bash
echo -n "Setting up"
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n " Done!"
sleep 1
clear
echo "Welcome to the (semi) automatic allegation creation tool"
echo "This tool simplifies the process of creating a list of acts for which to cancel a person on"
sleep 1
echo "Please enter the name of the person you would like to cancel"
read -p 'Name: ' name
sleep 1
echo "Enter a file path to create the list in. This will default to the working directory if left blank"
read -p 'Path: ' filepath
sleep 1
echo "Finally, please enter a list of the things $name has done. Separate each entry with commas."
read -p 'Acts: ' acts
sleep 1
echo "Does all of the following look correct?"
echo "Name: $name"
echo "Path: $filepath"
echo "Crimes: $acts"
echo "[Y/N]"
read confirm
while [[ "$confirm" != "y" && "$confirm" != "n" ]]; do
  read -p "Invalid input. Please enter y or n: " confirm
done

if [[ "$confirm" == "y" ]]; then
  echo "Continuing..."
  sleep 1
else
  echo "Exiting..."
  exit
fi
if [[ "$filepath" == "" ]]; then
    echo "No filepath specified. Defaulting to working directory..."
    sleep 1
else
    cdoutput="$(cd "$filepath" 2>&1)"
    cderror=$?
    sleep 1
    if [[ cderror -eq 1 ]]; then
        echo "Error: Entered directory is invalid or does not exist."
        echo -n "Attempting to create directory..."
        sleep 1
        mkdir $filepath
        echo " Done!"
        cd "$filepath"
        sleep 1
    fi
fi
echo -n "Parsing acts..."
sortedacts=$(echo "$acts" | tr ',' '\n')
echo " Done!"
sleep .25
echo -n "Creating file..."
echo "$sortedacts" > "$name"-allegations.txt
sleep 1
echo " Done!"
sleep .5
echo "Successfully created file '$name'-allegations.txt with contents:"
cat "$name"-allegations.txt
