#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Source Libraries ===
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"


# === Automated Mobile Scan Workflow ===
run_automated_mobile_scan() {

    #asking user for input file with validation
    while true; do
    read -p "Enter APK path: " APK_PATH
    #check if string is empty OR if file does NOT exist
    if [[ -z "$APK_PATH" ]]; then
        echo "Please enter a path to the input APK file"
    elif [[ ! -f "$APK_PATH" ]]; then
        echo "File does not exist at '$APK_PATH'"
    else 
        break
    fi
    done

    # Start Android Emulator
    echo -e "${BGreen}[*] Starting Android Emulator...${NC}"
    /opt/android-sdk/emulator/emulator -avd test_avd -writable-system &>/dev/null &
    adb wait-for-device

    # Install APK
    echo -e "${BGreen}[*] Installing APK...${NC}"
    adb install "$APK_PATH"

    # Start mitmproxy
    echo -e "${BGreen}[*] Starting mitmproxy...${NC}"
    mitmweb --web-host 0.0.0.0 &

    # Configure emulator to use mitmproxy
    echo -e "${BGreen}[*] Configuring emulator to use mitmproxy...${NC}"
    adb shell settings put global http_proxy 127.0.0.1:8080

    # Run MobSF
    echo -e "${BGreen}[*] Running MobSF scan...${NC}"
    cd /opt/Mobile-Security-Framework-MobSF
    ./run.sh

    echo -e "${BGreen}[+] Automated mobile scan completed.${NC}"
}

# === Main Execution ===
# 
# run_automated_mobile_scan
