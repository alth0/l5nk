#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

if ! command -v mmcli &>/dev/null || ! command -v nmcli &>/dev/null; then
    echo "Error: mmcli and/or nmcli not found. Please install ModemManager and NetworkManager." >&2
    exit 1
fi

echo "Checking for modems..."
mmcli -L

read -rp "Enter the modem index (from the list above): " MODEM_ID
if [[ -z "$MODEM_ID" ]]; then
    echo "Modem index cannot be empty." >&2
    exit 1
fi

echo "3GPP Information:"

mmcli -m $MODEM_ID | grep -A 5 '3GPP'

read -rp "Enter a name for the connection: " CONN_NAME
if [[ -z "$CONN_NAME" ]]; then
    echo "Connection name cannot be empty." >&2
    exit 1
fi

read -rp "Enter your APN: " APN
if [[ -z "$APN" ]]; then
    echo "APN cannot be empty." >&2
    exit 1
fi

echo "Checking if SIM needs unlocking..."
if mmcli -m "$MODEM_ID" | grep -q "state.*locked"; then
    read -rp "SIM is locked. Enter PIN: " PIN
    mmcli -i "$(mmcli -m "$MODEM_ID" | grep 'primary sim path' | awk '{print $NF}')" --pin="$PIN"
fi

echo "Creating NetworkManager connection with name: $CONN_NAME"
nmcli connection add type gsm ifname "*" con-name "$CONN_NAME" apn "$APN"

read -rp "Do you want to activate the connection now? (y/N): " ACTIVATE
if [[ "$ACTIVATE" =~ ^[Yy]$ ]]; then
    echo "Activating connection..."
    nmcli connection up "$CONN_NAME"
    echo "Modem connected successfully."
else
    echo "Connection has been created but not activated. You can activate it later with:"
    echo "nmcli connection up \"$CONN_NAME\""
fi
