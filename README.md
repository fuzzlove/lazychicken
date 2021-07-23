#!/bin/bash
#
# Run remotely: bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzzlove/lazychicken/main/lazychicken.sh)"
#
# This tool is designed to grab the currrent external ip configuration, and check external connectivity.
# Requirements: netcat, curl, ifconfig, ip, whois, bash
#
# It would be recommended to run a full update if using kali.
#

# IP Lookups (3 Sources ipchicken, icanhazip, and torguard)
#
# Networking tool for S3 by Joseph McPeters (liquidsky)
#
IP1=$(curl -s https://ipchicken.com | grep -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)
IP2=$(curl -s https://icanhazip.com/)
IP3=$(curl -s https://torguard.net/whats-my-ip.php | grep -m 2 -oE "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort -u | head -1)

echo "+-----------------------------------------------"
echo
echo -e "[*] \e[1;34m WHOIS Information: \e[0m"
echo
echo "+-----------------------------------------------"

# Function 1. Check if whois is installed - then whois external IP
if ! command -v whois &> /dev/null
then
    echo "[!] WHOIS could not be found"
    echo
    echo "Suggestion/Fix: sudo apt install whois"
    exit
fi
whois $IP1
# If ipchicken is blocked use the below options.

# whois $IP2
# whois $IP3

# Basic External IP Output
echo
echo "+-----------------------------------------------"
echo
echo -e "[*] \e[1;34m Checking External IP from multiple sources: \e[0m"
echo
echo "+-----------------------------------------------"
echo -e "[1] \033[31m IP Chicken: \e[0m $IP1"
echo
echo -e "[2] \033[31m Icanhazip: \e[0m $IP2"
echo
echo -e "[3] \033[31m Torguard: \e[0m $IP3"
echo
echo -e "[!] \e[1;34m Done \e[0m"
echo
echo "+-----------------------------------------------"
echo
echo -e "[*] \e[1;34m Internal IP Configuration: \e[0m"
echo
echo "+-----------------------------------------------"
echo

# Function 2. Check if ifconfig is installed - then run.
if ! command -v ifconfig &> /dev/null
then
    echo "[!] IFCONFIG command could not be found"
    exit
fi
echo -e "[1] \033[31m ~ Ifconfig ~: \e[0m"
ifconfig

# Function 3. Check if ip command is installed then run
if ! command -v ip &> /dev/null
then
    echo "[!] IP command could not be found"
    exit
fi
echo -e "[1] \033[31m ~ IP ~: \e[0m"
ip a

echo "+-----------------------------------------------"
echo
echo -e "[*] \e[1;34m Basic Network Checks (To See if Blocked): \e[0m"
echo
echo "+-----------------------------------------------"


# Function 4. Check if wget is available and then run it.

if ! command -v wget &> /dev/null
then
    echo "[!] wget command could not be found"
    exit
fi

# Function 5.
# As an alternative to wget check if netcat is available then run it.
# Checking connectivity to google, and s3security.com

if ! command -v nc &> /dev/null
then
    echo "[!] Netcat command could not be found"
    exit
fi

echo -e "[1] \033[31m Starting with GOOGLE\e[0m"

# WGET GOOGLE
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo -e "This box \e[46mCAN\e[0m reach google (via wget)"
else
    echo -e "This box can \e[46mNOT\e[0m connect to google. (via wget)"
fi

# NC GOOGLE
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "This box \e[46mCAN\e[0m reach google. (via netcat)"
else
    echo -e "This box can \e[46mNOT\e[0m connect to google. (via netcat)"
    echo "The network appears to be segmented from this check."
    
fi

# WGET S3
echo -e "[1] \033[31m Trying S3Security.com \e[0m"
wget -q --spider http://s3security.com

if [ $? -eq 0 ]; then
    echo -e "This box \e[46mCAN\e[0m reach s3security.com (via wget)"
else
    echo -e "This box can \e[46mNOT\e[0m connect to s3security.com. (via wget)"
    echo "The network appears to be segmented from this check."
fi

# NC S3
echo -e "GET http://s3security.com HTTP/1.0\n\n" | nc s3security.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "This box \e[46mCAN\e[0m reach s3security.com. (via netcat)"
else
    echo -e "This box can \e[46mNOT\e[0m connect to s3security.com. (via netcat)"
    echo "The network appears to be segmented from this check."
fi

echo
echo -e "[!] \e[1m\e[3m\e[31mDONE WITH ALL CHECKS\e[0m"
