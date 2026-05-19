#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"


# === Delta Report Generation ===
create_delta_report() {
    read -p "Enter the path to the first scan report: " report1
    read -p "Enter the path to the second scan report: " report2

    if [ ! -f "$report1" ] || [ ! -f "$report2" ]; then
        echo -e "${BRed}Error: One or both report files not found.${NC}"
        return 1
    fi

    timestamp=$(date +%F_%H-%M-%S)
    AUTOMATED_DELTA_REPORT_OUTPUT_DIR="$OUTPUT_DIR/automated_delta_report/$timestamp"
    mkdir -p $AUTOMATED_DELTA_REPORT_OUTPUT_DIR

    echo -e "${BGreen}[*] Generating delta report...${NC}"

    delta_report="$AUTOMATED_DELTA_REPORT_OUTPUT_DIR/delta_report.txt"

    echo -e "${BYellow}### New Vulnerabilities ###${NC}" > "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\+' | sed 's/^\+//' >> "$delta_report"

    echo -e "\n${BYellow}### Fixed Vulnerabilities ###${NC}" >> "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\-' | sed 's/^\-//' >> "$delta_report"

    echo -e "${BGreen}[+] Delta report generated: $delta_report${NC}"
}

# === Main Execution ===

# create_delta_report
