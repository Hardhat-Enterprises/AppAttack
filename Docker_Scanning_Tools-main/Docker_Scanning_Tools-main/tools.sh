#!/bin/bash

# Colors for echo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define log file
LOG_FILE="$HOME/security_tools.log"

# Function to display help menu
display_help() {
    echo -e "${YELLOW}Interactive Help Menu:${NC}"
    echo "1) osv-scanner: Scan a directory for vulnerabilities"
    echo "   - Download: https://github.com/google/osv-scanner"
    echo "2) snyk cli: Test code locally or monitor for vulnerabilities"
    echo "   - Download: https://snyk.io/download/"
    echo "   - Run code test locally: snyk code test <directory>"
    echo "   - Monitor for vulnerabilities: snyk monitor <directory> --all-projects"
    echo "3) brakeman: Scan a Ruby on Rails application for security vulnerabilities"
    echo "   - Download: https://github.com/presidentbeef/brakeman"
    echo "4) nmap: Network exploration and security auditing tool"
    echo "   - Download: https://nmap.org/download.html"
    echo "5) nikto: Web server scanner"
    echo "   - Download: https://cirt.net/nikto/"
    echo "6) LEGION: Automated web application security scanner"
    echo " - Download: https://github.com/GoVanguard/legion"    
    echo "7) OWASP ZAP: Web application security testing tool"
    echo "   - Download: https://github.com/zaproxy/zaproxy/releases"
    echo "8) Learning resources: Learn about most common vulnerabilities in web security"
    echo "   - Access: https://www.linkedin.com/pulse/10-common-web-security-vulnerabilities-bkplussoftware-2wzrc/"
    echo "9) Help: Display this help menu"
    echo "10) Exit: Exit the script"
}

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Function to check for updates and update tools
check_updates() {
    log_message "Checking for updates..."
     apt update
     gem update brakeman
    # Remove existing snyk installation
     npm uninstall -g snyk
     npm install -g snyk
}


# Function to install Go if not installed
install_go() {
    echo -e "${YELLOW}Installing Go...${NC}"
     apt update &&  apt install -y golang-go
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Go installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install Go.${NC}"
        exit 1
    fi
}

# Function to install npm if not installed
install_npm() {
    echo -e "${YELLOW}Installing npm...${NC}"
     apt update &&  apt install -y npm
    if [ $? -eq 0 ]; then
         chown -R $(whoami) ~/.npm
        echo -e "${GREEN}npm installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install npm.${NC}"
        exit 1
    fi
}

# Function to install osv-scanner
install_osv_scanner() {
    if ! command -v osv-scanner &> /dev/null; then
        echo -e "${YELLOW}Installing osv-scanner...${NC}"
        go install github.com/google/osv-scanner/cmd/osv-scanner@v1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}osv-scanner installed successfully!${NC}"
            echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
            source ~/.bashrc
        else
            echo -e "${RED}Failed to install osv-scanner.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}osv-scanner is already installed.${NC}"
    fi
}

install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    if ! command -v snyk &> /dev/null; then
        echo -e "${YELLOW}Installing snyk cli...${NC}"
        # Check if snyk file exists, remove it if it does
        if [ -f /usr/local/bin/snyk ]; then
             rm /usr/local/bin/snyk
        fi
        # Add a short sleep command to ensure the file is removed
        sleep 1
         npm install -g snyk
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Snyk cli installed successfully!${NC}"
            echo -e "${YELLOW}Authenticating snyk...${NC}"
            echo -e "${RED}Please authenticate by clicking 'Authenticate' in the browser to continue.${NC}"
            snyk auth
        else
            echo -e "${RED}Failed to install snyk cli.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}

# Function to install brakeman
install_brakeman() {
    if ! command -v brakeman &> /dev/null; then
        echo -e "${YELLOW}Installing brakeman...${NC}"
         gem install brakeman
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Brakeman installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install brakeman.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}brakeman is already installed.${NC}"
    fi
}

# Function to install nmap
install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}Installing nmap...${NC}"
         apt update &&  apt install -y nmap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nmap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nmap.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}nmap is already installed.${NC}"
    fi
}

# Function to install nikto
install_nikto() {
    if ! command -v nikto &> /dev/null; then
        echo -e "${YELLOW}Installing nikto...${NC}"
         apt update &&  apt install -y nikto
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nikto installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nikto.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}nikto is already installed.${NC}"
    fi
}
# Function to install LEGION
install_legion() {
    if ! command -v legion &> /dev/null; then
        echo -e "${YELLOW}Installing LEGION...${NC}"
         apt update
         apt install -y legion
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}LEGION installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install LEGION.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}LEGION is already installed.${NC}"
    fi
}
# Function to install OWASP ZAP
install_owasp_zap() {
    if ! command -v zap.sh &> /dev/null; then
        echo -e "${YELLOW}Installing OWASP ZAP...${NC}"
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz
        if [ $? -eq 0 ]; then
            tar -xvf ZAP_2.15.0_Linux.tar.gz
             rm -rf /opt/owasp-zap/ZAP_2.15.0
             mv ZAP_2.15.0 /opt/owasp-zap
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}OWASP ZAP installed successfully!${NC}"
            else
                echo -e "${RED}Failed to move OWASP ZAP.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download OWASP ZAP.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}OWASP ZAP is already installed.${NC}"
    fi
}

# Function to install Go if not installed
# Remaining functions...

# Function to run OWASP ZAP and convert HTML report to text
run_owasp_zap() {
    local target_url="$1"
    local output="$2"
    /opt/owasp-zap/zap.sh -cmd -quickurl "$target_url" -quickout "/home/kali/owasp-zap-results.html"
    echo -e "${GREEN}OWASP ZAP scan completed.${NC}"
    log_message "OWASP ZAP scan completed for $target_url"

    # Convert HTML report to text
    if [ -f "/home/kali/owasp-zap-results.html" ]; then
        echo -e "${YELLOW}Converting HTML report to text...${NC}"
        html2text "/home/kali/owasp-zap-results.html" > "/home/kali/owasp-zap-results.txt"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Conversion successful! Text report saved as /home/kali/owasp-zap-results.txt.${NC}"
            log_message "OWASP ZAP HTML report converted to text"
        else
            echo -e "${RED}Failed to convert HTML report to text.${NC}"
            log_message "Failed to convert OWASP ZAP HTML report to text"
        fi
    else
        echo -e "${RED}HTML report not found. Skipping conversion.${NC}"
        log_message "OWASP ZAP HTML report not found. Skipping conversion."
    fi
}

# Function to save vulnerabilities to file
save_vulnerabilities() {
    local tool=$1
    local output_file="$tool-vulnerabilities.txt"
    case $tool in
        "osv-scanner")
            osv-scanner scan "./$directory" > "$output_file"
            ;;
        "snyk")
            snyk code scan > "$output_file"
            ;;
        "brakeman")
             brakeman --force > "$output_file"
            ;;
        "nmap")
            nmap -v -A "$url" > "$output_file"
            ;;
        "nikto")
            nikto -h "$url" > "$output_file"
            ;;
        "legion")
            legion "$url" > "$output_file"
            ;;
    esac
    echo -e "${GREEN}Vulnerabilities found:${NC}"
    cat "$output_file"
    read -p "Do you want to save the vulnerabilities to a file? (y/n) " save_to_file
    if [[ "$save_to_file" == "y" ]]; then
        echo -e "${GREEN}Vulnerabilities saved to $output_file${NC}"
    else
        echo -e "${GREEN}Vulnerabilities not saved to a file.${NC}"
    fi
}

# Main function to check and install tools
main() {
 
   # Initialize log file
    echo "" > "$LOG_FILE"
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        install_go
    fi
    # Check and install osv-scanner
    install_osv_scanner
    # Check and install snyk cli
    install_snyk_cli
    # Check and install brakeman
    install_brakeman
    # Check and install nmap
    install_nmap
    # Check and install nikto
    install_nikto
    # Check and install LEGION
    install_legion    
    # Check and install OWASP ZAP
    install_owasp_zap
    
   # Check for updates
    check_updates

    # Check if npm is installed and install if not
    # Remaining checks...

    # Display help menu
    display_help
    
    while true; do
    # Display help menu
    display_help

    read -p "Choose an option (9 for help): " choice
    
    output=""
    if [[ "$choice" != "6" ]]; then
        read -p "Do you want to output the results to a text file? Results are saved to /home/kali (y/n): " output_to_file
        if [[ "$output_to_file" == "y" ]]; then
            case $choice in
                1) output=" > /home/kali/osv-scanner-results.txt" ;;
                2) output=" > /home/kali/snyk-results.txt" ;;
                3) output=" > /home/kali/brakeman-results.txt" ;;
                4) output=" > /home/kali/nmap-results.txt" ;;
                5) output=" > /home/kali/nikto-results.txt" ;;
                7) output=" > /home/kali/owasp-zap-results.txt" ;;
            esac
        fi
    fi

        case $choice in
            1)
                read -p "Enter directory to scan: " directory
                source ~/.bashrc
                osv-scanner --recursive "$directory" > $output
                ;;
            2)
                read -p "Select Snyk option:
                1) Run code test locally
                2) Monitor for vulnerabilities and see results in Snyk UI
                Enter your choice (1/2): " snyk_option
                case $snyk_option in
                    1)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk code test $directory > $output
                        ;;
                    2)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk monitor $directory --all-projects > $output
                        ;;
                    *)
                        echo -e "${RED}Invalid choice!${NC}"
                        ;;
                esac
                ;;
            3)
                read -p "Enter directory to scan (current directory ./): " directory
                 brakeman $directory --force > $output
                ;;
            4)
                read -p "Enter URL or IP address to scan: " url
                nmap -v -A -oG - "$url" > $output
                ;;
            5)
                read -p "Enter URL to scan: " url
                nikto -h $url > $output
                ;;
            6)
                legion 
                ;;                 
            7)
                run_owasp_zap
                ;;
            8)
                echo -e "${YELLOW}Exiting...${NC}"
                exit 0
                ;;
            9)
                display_help
                ;;
            10)
                # Learning resources link
                echo -e "${YELLOW}Learning resources: Learn about most common vulnerabilities in web security${NC}"
                echo -e "${GREEN}Access: https://www.linkedin.com/pulse/10-common-web-security-vulnerabilities-bkplussoftware-2wzrc/${NC}"
                ;;
           
            11)
                echo -e "${YELLOW}Exiting...${NC}"
                log_message "Script ended"
                exit 0
                ;;
            12)
                echo -e "${RED}Invalid choice, please try again.${NC}"
                log_message "Invalid user input"
                ;;
          
        esac
    done
}

# Execute main function
main
