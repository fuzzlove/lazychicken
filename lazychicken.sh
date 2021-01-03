#!/bin/bash

#
# Run remotely: bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzzlove/lazychicken/main/lazychicken.sh)"
#


IP1=$(curl -s https://ipchicken.com | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)
IP2=$(curl -s https://icanhazip.com/)
IP3=$(curl -s https://torguard.net/whats-my-ip.php | grep -m 2 -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)

echo -e "[*] \e[1;34m Checking IP from multiple sources: \e[0m"
echo
echo -e "[1] \033[31m IP Chicken: \e[0m $IP1"
echo
echo -e "[2] \033[31m Icanhazip: \e[0m $IP2"
echo
echo -e "[3] \033[31m Torguard: \e[0m $IP3"
echo
echo -e "[!] \e[1;34m Done \e[0m"
