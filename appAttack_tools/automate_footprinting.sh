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

# === Default Variables ===
TARGET_DOMAIN=""

# === Footprinting Workflow ===
run_footprinting_workflow() {
    
    read -p "Enter target domain: " target_domain

    timestamp=$(date +%F_%H-%M-%S)
    AUTOMATED_FOOTPRINTING_OUTPUT_DIR="$OUTPUT_DIR/automated_footprinting/$timestamp"
    mkdir -p $AUTOMATED_FOOTPRINTING_OUTPUT_DIR

    echo -e "${BGreen}[*] Running subfinder on $target_domain...${NC}"
    subfinder -d "$target_domain" -o "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/subdomains.txt"

    #if no subdomains are found, return
    if [[ ! -s "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/subdomains.txt" ]]; then 
        echo "No subdomains found"
        echo -e "${BGreen}Footprinting workflow completed. Results in $AUTOMATED_FOOTPRINTING_OUTPUT_DIR${NC}"
        return 1
    fi

    echo -e "${BGreen}[*] Running httpx on the discovered subdomains...${NC}"
    httpx-toolkit -l "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/subdomains.txt" -o "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/live_hosts.txt"
        
    #if no lives hosts are found, return
    if [[ ! -s "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/live_hosts.txt" ]]; then
        echo "No live hosts found"
        echo -e "${BGreen}Footprinting workflow completed. Results in $AUTOMATED_FOOTPRINTING_OUTPUT_DIR${NC}"
        return 1
    fi

    echo -e "${BGreen}[*] Running nmap on the live hosts...${NC}"
    nmap -iL "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/live_hosts.txt" -oN "$AUTOMATED_FOOTPRINTING_OUTPUT_DIR/nmap_scan.txt"

    echo -e "${BGreen}Footprinting workflow completed. Results in $AUTOMATED_FOOTPRINTING_OUTPUT_DIR${NC}"




}

