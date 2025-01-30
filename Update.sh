#!/bin/bash
echo "Updating packages..."
yay -Syu
echo "Finished."
sleep 1
echo "Updating flatpaks..."
flatpak update
echo "Finished."
sleep 1
echo "Updating rust..."
rustup update
echo "Finished."
sleep 1
echo "Cleaning up..."
echo "Checking for orphaned packages..."
orphans=$(pacman -Qdt | wc -l)
if [ $orphans -gt 0 ]; then
    echo "$orphans orphaned packages found."
    pacman -Qdt | awk '{print $1}'
    echo "Remove these? [y/N]"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo pacman -Rns $(pacman -Qdtq)
        echo "Done!"
    else
        echo "Skipping removal."
    fi
else
    echo "No orphaned packages to remove."
fi
echo "Cleaning package cache..."
sudo paccache -r
echo "Cleaning flatpak cache..."
sudo flatpak repair
echo "Libraries repaired."
flatpak uninstall --unused
echo "Unused flatpaks removed."
echo "Clearing user cache..."
rm -rf ~/.cache/*
echo "Done!"
echo "Update and maintenence complete."


