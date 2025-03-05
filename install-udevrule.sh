#!/bin/bash

UDEV_RULE="99-hp-lt4120.rules"
SRC_PATH="./$UDEV_RULE"
DEST_PATH="/etc/udev/rules.d/$UDEV_RULE"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

if [[ ! -f "$SRC_PATH" ]]; then
    echo "Error: Udev rule file '$SRC_PATH' not found!" >&2
    exit 1
fi

echo "Starting installation"

sleep 1

echo "Installing udev rule: $UDEV_RULE"
cp "$SRC_PATH" "$DEST_PATH"

chmod 644 "$DEST_PATH"

echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Installation complete."

