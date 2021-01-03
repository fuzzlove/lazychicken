#!/bin/bash

#
# Run remotely: bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzzlove/lazychicken/main/lazychicken.sh)"
#


IP1=$(curl -s https://ipchicken.com | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)
IP2=$(curl -s https://icanhazip.com/)
IP3=$(curl -s https://torguard.net/whats-my-ip.php | grep -m 2 -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)

echo "[*] Checking External IP from multiple sources:"
echo
echo -e "\033[31m [1] IP Chicken: \e[0m $IP1"
echo
echo -e "\033[31m [2] Icanhazip: \e[0m $IP2"
echo
echo -e "\033[31m [3] Torguard: \e[0m $IP3"
echo
echo "[!] Done"
