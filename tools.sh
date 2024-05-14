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

    while true; do
        # Run tools
        echo -e "${YELLOW}Select the tool you want to run:${NC}"
        echo "1) osv-scanner"
        echo "2) snyk cli"
        echo "3) brakeman Note: To scroll through pages press space, to exit the results page press q"
        echo "4) nmap"
        echo "5) nikto"
        echo "6) Run all"
        echo "7) Exit"
        read -p "Enter your choice (1/2/3/4/5/6/7): " choice

        case $choice in
            1)
                read -p "Enter directory to scan (current directory ./): " directory
                osv-scanner scan "./$directory"
                ;;
            2)
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
        ;;
            3)
                sudo brakeman --force
                ;;
            4)
                read -p "Enter URL to scan: " url
                nmap -v -A "$url"
                ;;
            5)
                read -p "Enter URL to scan: " url
                nikto -h "$url"
                ;;
            6)
                read -p "Enter directory to scan (current directory ./): " directory
                osv-scanner scan "./$directory"
                snyk code test "$directory"
                sudo brakeman --force
                read -p "Enter URL to scan: " url
                nmap -v -A"$url"
                read -p "Enter URL to scan: " url
                nikto -h "$url"
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

# Run the main function
main

