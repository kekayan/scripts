#!/bin/bash

UNI_USERNAME="knan475"
SERVER="nas1.bioeng.auckland.ac.nz"
SHARE="hpc"
MOUNTDIR="$HOME/hpc"

# Get password from Keychain
PASSWORD=$(security find-generic-password -a "$UNI_USERNAME" -s "uoa-nas1-hpc" -w 2>/dev/null)

if [ -z "$PASSWORD" ]; then
    echo "No password found in Keychain. Let's add it now."
    echo -n "Enter password for $UNI_USERNAME: "
    read -s PASSWORD
    echo
    security add-generic-password -a "$UNI_USERNAME" -s "uoa-nas1-hpc" -w "$PASSWORD"
    echo "Password saved to Keychain."
fi

# Create mount point
if [ ! -d "$MOUNTDIR" ]; then
    mkdir -p "$MOUNTDIR"
fi

# Check if already mounted
if mount | grep -q "$MOUNTDIR"; then
    echo "$MOUNTDIR is already mounted"
else
    mount_smbfs "//uoa;${UNI_USERNAME}:${PASSWORD}@${SERVER}/${SHARE}" "$MOUNTDIR"
    if [ $? -eq 0 ]; then
        echo "Mounted successfully at $MOUNTDIR"
    else
        echo "Mount failed"
        exit 1
    fi
fi
