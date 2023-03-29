#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# check if we already have sudo permission
sudo -n true 2>/dev/null || {
    echo "Enter your password to give me permission to flash the firmware"
    sudo -v
}

echo "Downloading firmware..."
dotenv run ./download.sh scratch/firmware.zip

unzip -o scratch/firmware.zip -d scratch > /dev/null

green="\033[32m"
reset="\033[0m"

whileDir() {
    not="$1"
    root="$2"
    i=0
    while [ $not -d "$root" ]; do
        if [ $((i & (i - 1))) -eq 0 ]; then echo -n "."; fi
        sleep 1
        i=$((i + 1))
    done
}

load() {
    side="$1"
    sidec="$green$side$reset"
    echo
    echo -e "2. Turn off $sidec"
    echo -e "1. Connect the $sidec half via USB"
    echo -e "3. Press the RESET button twice on the $sidec"
    echo -e "4. Ignore the ejection error https://zmk.dev/docs/troubleshooting#file-transfer-error"
    echo

    root="/Volumes/NRF52BOOT"

    if [ ! -d "$root" ]; then
        echo -n "Waiting for $root to appear "
    fi

    whileDir "!" "$root"

    echo
    echo

    echo cp scratch/*"$side"* "$root/CURRENT.UF2"
    sudo cp scratch/*"$side"* "$root/CURRENT.UF2"

    if [ -d "$root" ]; then
        echo "Waiting for $root to disappear (or run 'sudo rm -rf /Volumes/NRF52BOOT')"
    fi

    whileDir "" "$root"
}

load left
load right

echo
echo "Now you can turn on the keyboard and enjoy your new firmware!"
echo
