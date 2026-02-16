#!/bin/bash

UNI_USERNAME="knan475"
KEYCHAIN_SERVICE="uoa-vpn"
OTP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --otp)
            OTP="$2"
            shift 2
            ;;
        *)
            echo "Usage: ./vpn.sh --otp <code>"
            exit 1
            ;;
    esac
done

if [ -z "$OTP" ]; then
    echo "OTP is required: ./vpn.sh --otp <code>"
    exit 1
fi

# Get password from Keychain
PASSWORD=$(security find-generic-password -a "$UNI_USERNAME" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null)

if [ -z "$PASSWORD" ]; then
    echo "No VPN password found in Keychain. Let's add it now."
    echo -n "Enter password for $UNI_USERNAME: "
    read -s PASSWORD
    echo
    security add-generic-password -a "$UNI_USERNAME" -s "$KEYCHAIN_SERVICE" -w "$PASSWORD"
    echo "Password saved to Keychain."
fi

# VPN config
HOST="connectvpn.auckland.ac.nz"
PORT="443"
REALM="client"

# Run openfortivpn with password and OTP piped in
echo -e "${PASSWORD}\n${OTP}" | sudo openfortivpn "$HOST:$PORT" -u "$UNI_USERNAME" --realm="$REALM"
