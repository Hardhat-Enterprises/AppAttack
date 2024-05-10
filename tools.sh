#!/bin/bash

# Colors for echo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to install Go if not installed
install_go() {
    echo -e "${YELLOW}Installing Go...${NC}"
    sudo apt update
    sudo apt install -y golang-go
    echo -e "${GREEN}Go installed successfully!${NC}"
}

# Function to install npm if not installed
install_npm() {
    echo -e "${YELLOW}Installing npm...${NC}"
    sudo apt update
    sudo apt install -y npm
    sudo chown -R $(whoami) ~/.npm
    echo -e "${GREEN}npm installed successfully!${NC}"
}

# Function to install osv-scanner
install_osv_scanner() {
    if ! command -v osv-scanner &> /dev/null; then
        echo -e "${YELLOW}Installing osv-scanner...${NC}"
        go install github.com/google/osv-scanner/cmd/osv-scanner@v1
        echo -e "${GREEN}osv-scanner installed successfully!${NC}"
        echo "export PATH=\$PATH:$(go env GOPATH)/bin" >> ~/.bashrc
        source ~/.bashrc
    else
        echo -e "${GREEN}osv-scanner is already installed.${NC}"
    fi
}

# Function to install snyk cli
install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi

    if ! command -v snyk &> /dev/null; then
        echo -e "${YELLOW}Installing snyk cli...${NC}"
        sudo npm install -g snyk
        echo -e "${GREEN}Snyk cli installed successfully!${NC}"
        echo -e "${YELLOW}Authenticating snyk...${NC}"
        echo -e "${RED}Please authenticate by clicking 'Authenticate' in the browser to continue.${NC}"
        snyk auth
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}

# Function to install brakeman
install_brakeman() {
    if ! command -v brakeman &> /dev/null; then
        echo -e "${YELLOW}Installing brakeman...${NC}"
        sudo gem install brakeman
        echo -e "${GREEN}Brakeman installed successfully!${NC}"
    else
        echo -e "${GREEN}brakeman is already installed.${NC}"
    fi
}

# Function to install nmap
install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}Installing nmap...${NC}"
        sudo apt update
        sudo apt install -y nmap
        echo -e "${GREEN}nmap installed successfully!${NC}"
    else
        echo -e "${GREEN}nmap is already installed.${NC}"
    fi
}

# Function to install nikto
install_nikto() {
    if ! command -v nikto &> /dev/null; then
        echo -e "${YELLOW}Installing nikto...${NC}"
        sudo apt update
        sudo apt install -y nikto
        echo -e "${GREEN}nikto installed successfully!${NC}"
    else
        echo -e "${GREEN}nikto is already installed.${NC}"
    fi
}

# Function to install OWASP ZAP
install_owasp_zap() {
    if ! command -v zap.sh &> /dev/null; then
        echo -e "${YELLOW}Installing OWASP ZAP...${NC}"
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.10.0/ZAP_2.10.0_Crossplatform.zip
        unzip ZAP_2.10.0_Crossplatform.zip
        mv ZAP_2.10.0 /opt/owasp-zap
        echo -e "${GREEN}OWASP ZAP installed successfully!${NC}"
    else
        echo -e "${GREEN}OWASP ZAP is already installed.${NC}"
    fi
}

# Function to run OWASP ZAP
run_owasp_zap() {
    read -p "Enter target URL to scan: " target_url
    /opt/owasp-zap/zap.sh -cmd -quickurl $target_url -quickout /home/kali/owasp-zap-results.html
    echo -e "${GREEN}OWASP ZAP scan completed.${NC}"
}

# Main function to check and install tools
main() {
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

    # Check and install OWASP ZAP
    install_owasp_zap

    while true; do
        # Run tools
        echo -e "${YELLOW}Select the tool you want to run:${NC}"
        echo "1) osv-scanner"
        echo "2) snyk cli"
        echo "3) brakeman"
        echo "4) nmap"
        echo "5) nikto"
        echo "6) OWASP ZAP"
        echo "7) Run all"
        echo "8) Exit"
        read -p "Enter your choice (1/2/3/4/5/6/7/8): " choice
        read -p "Do you want to output the results to a text file? Results are saved to /home/kali (y/n): " output_to_file

        # Write each tool output to their own individual txt file
        output=""
        if [[ "$output_to_file" == "y" ]]; then
            case $choice in
                1) output=" > /home/kali/osv-scanner-results.txt" ;;
                2) output=" > /home/kali/snyk-results.txt" ;;
                3) output=" > /home/kali/brakeman-results.txt" ;;
                4) output=" > /home/kali/nmap-results.txt" ;;
                5) output=" > /home/kali/nikto-results.txt" ;;
                6) output=" > /home/kali/owasp-zap-results.html" ;;
                7) output=" > /home/kali/all-tools-results.txt" ;;
            esac
        fi

        case $choice in
            1)
                read -p "Enter directory to scan (current directory ./): " directory
                osv-scanner scan "$directory"$output
                ;;
            2)
                read -p "Select Snyk option:
                1) Run code test locally
                2) Monitor for vulnerabilities and see results in Snyk UI
                Enter your choice (1/2): " snyk_option

                case $snyk_option in
                    1)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk code test $directory$output
                        ;;
                    2)
                        read -p "Enter directory to scan (current directory ./): " directory
                        snyk monitor $directory --all-projects$output
                        ;;
                    *)
                        echo -e "${RED}Invalid choice!${NC}"
                        ;;
                esac
                ;;
            3)
                sudo brakeman --force$output
                ;;
            4)
                read -p "Enter URL to scan: " url
                nmap -v -A "$url"$output
                ;;
            5)
                read -p "Enter URL to scan: " url
                nikto -h "$url"$output
                ;;
            6)
                if [[ "$output_to_file" == "y" ]]; then
                    echo -e "${YELLOW}Running osv-scanner...${NC}"
                    read -p "Enter directory to scan (current directory ./): " directory
                    osv-scanner scan "$directory" > /home/kali/osv-scanner-results.txt
                    echo -e "${YELLOW}Running snyk...${NC}"
                    read -p "Select Snyk option:
                    1) Run code test locally
                    2) Monitor for vulnerabilities and see results in Snyk UI
                    Enter your choice (1/2): " snyk_option

                    case $snyk_option in
                        1)
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk code test $directory > /home/kali/snyk-results.txt
                            ;;
                        2)
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk monitor $directory --all-projects > /home/kali/snyk-results.txt
                            ;;
                        *)
                            echo -e "${RED}Invalid choice!${NC}"
                            ;;
                    esac
                    echo -e "${YELLOW}Running brakeman...${NC}"
                    sudo brakeman --force > /home/kali/brakeman-results.txt
                    echo -e "${YELLOW}Running nmap...${NC}"
                    read -p "Enter a hostname or IP address to scan: " url
                    read -p "Enter a port to scan: " port
                    nmap -p "$port" -v -A "$url" > /home/kali/nmap-results.txt
                    echo -e "${YELLOW}Running nikto...${NC}"
                    read -p "Enter URL to scan: " url
                    nikto -h "$url" > /home/kali/nikto-results.txt
                    echo -e "${GREEN}Done!.${NC}"
                else
                    echo -e "${YELLOW}Running osv-scanner...${NC}"
                    read -p "Enter directory to scan (current directory ./): " directory
                    osv-scanner scan "$directory"
                    echo -e "${YELLOW}Running snyk...${NC}"
                    read -p "Select Snyk option:
                    1) Run code test locally
                    2) Monitor for vulnerabilities and see results in Snyk UI
                    Enter your choice (1/2): " snyk_option

                    case $snyk_option in
                        1)
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk code test $directory
                            ;;
                        2)
                            read -p "Enter directory to scan (current directory ./): " directory
                            snyk monitor $directory --all-projects
                            ;;
                        *)
                            echo -e "${RED}Invalid choice!${NC}"
                            ;;
                    esac
                    echo -e "${YELLOW}Running brakeman...${NC}"
                    sudo brakeman --force
                    echo -e "${YELLOW}Running nmap...${NC}"
                    read -p "Enter a hostname or IP address to scan: " url
                    read -p "Enter a port to scan: " port
                    nmap -p "$port" -v -A "$url"
                    echo -e "${YELLOW}Running nikto...${NC}"
                    read -p "Enter URL to scan: " url
                    nikto -h "$url"
                    echo -e "${GREEN}Done!.${NC}"
                fi
                ;;
            7)
                echo -e "${GREEN}Exiting.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice!${NC}"
                ;;
        esac
    done
}
