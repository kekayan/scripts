#!/bin/bash

MOUNTDIR="$HOME/hpc"

if mount | grep -q "$MOUNTDIR"; then
    umount "$MOUNTDIR"
    if [ $? -eq 0 ]; then
        echo "Unmounted $MOUNTDIR successfully"
    else
        echo "Normal unmount failed, trying force unmount..."
        diskutil unmount force "$MOUNTDIR"
    fi
else
    echo "$MOUNTDIR is not mounted"
fi
