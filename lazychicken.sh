#!/bin/bash

# lazychicken.sh - A lazy simple external IP check that utilizes curl with ipchicken.com :)
#
# Run remotely: bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzzlove/lazychicken/main/lazychicken.sh)"
#

echo "Lazychicken.sh - By: LiquidSky"
echo
echo "A lazy simple external IP check that utilizes ipchicken + curl"
echo
IP=$(curl -s https://ipchicken.com | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u)

echo -e "\033[31mCurrent IP: \e[0m $IP"
