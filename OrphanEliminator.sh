#!/bin/bash
echo "Checking for orphan packages..."
orphans=$(pacman -Qdt)
error=$?
if [ "$error" = 1 ]; then
    echo "Unexpected error: $orphans"
    exit 1
fi
echo "Orphans found: $orphans"
echo "Removing..."
sudo pacman -Rs "$orphans"
echo "Removal sucessful"
exit