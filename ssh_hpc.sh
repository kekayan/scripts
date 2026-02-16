#!/bin/bash

UNI_USERNAME="knan475"
KEYCHAIN_SERVICE="uoa-hpc"
DEFAULT_HPC="7"
GATEWAY="bioeng10.bioeng.auckland.ac.nz"
HPC_DOMAIN="bioeng.auckland.ac.nz"
USE_X=false
USE_GATEWAY=false
OTP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --hpc)
            HPC_NUM="$2"
            shift 2
            ;;
        --machine)
            MACHINE="$2"
            shift 2
            ;;
        --otp)
            OTP="$2"
            shift 2
            ;;
        -x|--x11)
            USE_X=true
            shift
            ;;
        --gateway)
            USE_GATEWAY=true
            shift
            ;;
        -h|--help)
            echo "Usage: ssh-hpc [options]"
            echo ""
            echo "Options:"
            echo "  --hpc <number>   HPC machine number (default: $DEFAULT_HPC)"
            echo "  --machine <name> Connect to a specific machine (e.g. BN82300)"
            echo "  --otp <code>     OTP token for 2FA (password:token)"
            echo "  -x, --x11        Enable X11 forwarding (off by default)"
            echo "  --gateway        Connect via bioeng10 gateway (no VPN needed)"
            echo "  -h, --help       Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage info"
            exit 1
            ;;
    esac
done

# Get password from Keychain
PASSWORD=$(security find-generic-password -a "$UNI_USERNAME" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null)

if [ -z "$PASSWORD" ]; then
    echo "No HPC password found in Keychain. Let's add it now."
    echo -n "Enter password for $UNI_USERNAME: "
    read -s PASSWORD
    echo
    security add-generic-password -a "$UNI_USERNAME" -s "$KEYCHAIN_SERVICE" -w "$PASSWORD"
    echo "Password saved to Keychain."
fi

HPC_NUM="${HPC_NUM:-$DEFAULT_HPC}"
SSH_FLAGS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"
if $USE_X; then
    SSH_FLAGS="$SSH_FLAGS -Y"
fi

if [ -n "$MACHINE" ]; then
    TARGET="${UNI_USERNAME}@${MACHINE}"
else
    TARGET="${UNI_USERNAME}@hpc${HPC_NUM}.${HPC_DOMAIN}"
fi

if $USE_GATEWAY; then
    if [ -z "$OTP" ]; then
        echo "OTP is required when using gateway (no VPN): ssh-hpc --gateway --otp <code>"
        exit 1
    fi
    SSH_PASSWORD="${PASSWORD}:${OTP}"
    echo "Connecting via gateway ($GATEWAY) -> $TARGET"
    expect -c "
        set timeout 30
        spawn ssh $SSH_FLAGS -J ${UNI_USERNAME}@${GATEWAY} $TARGET
        expect {
            \"*assword*\" { send \"${SSH_PASSWORD}\r\"; exp_continue }
            \"*\\\$*\" { interact }
            \"*%*\" { interact }
            \"*>*\" { interact }
        }
    "
else
    echo "Connecting to $TARGET"
    expect -c "
        set timeout 30
        spawn ssh $SSH_FLAGS $TARGET
        expect \"*assword*\"
        send \"${PASSWORD}\r\"
        interact
    "
fi
