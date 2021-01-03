#!/bin/bash

# lazychicken.sh - A lazy simple external IP check that utilizes curl with ipchicken.com :)
#

echo "Lazychicken.sh - By: LiquidSky"
echo
echo "A lazy simple external IP check that utilizes ipchicken + curl"
echo
IP=$(curl -s https://ipchicken.com | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u)

echo -e "\033[31mCurrent IP: \e[0m $IP"
