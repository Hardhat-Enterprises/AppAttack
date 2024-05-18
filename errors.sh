#!/bin/bash

# Colors for echo
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# MySQL connection details
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASSWORD="your_mysql_password"
MYSQL_DB="vulnerabilities"
MYSQL_TABLE="vulnerabilities"

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

# Function to install LEGION
install_legion() {
    if ! command -v legion &> /dev/null; then
        echo -e "${YELLOW}Installing LEGION...${NC}"
        sudo apt update
        sudo apt install -y legion
        echo -e "${GREEN}LEGION installed successfully!${NC}"
    else
        echo -e "${GREEN}LEGION is already installed.${NC}"
    fi
}

# Function to save vulnerabilities to file and database
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
            sudo brakeman --force > "$output_file"
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

    read -p "Do you want to store the vulnerabilities in a database? (y/n) " store_in_db
    if [[ "$store_in_db" == "y" ]]; then
        while read -r line; do
            mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" -e "INSERT INTO $MYSQL_TABLE (tool, vulnerability) VALUES ('$tool', '$line');"
        done < "$output_file"
        echo -e "${GREEN}Vulnerabilities stored in the database.${NC}"
    else
        echo -e "${GREEN}Vulnerabilities not stored in the database.${NC}"
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

    # Check and install LEGION
    install_legion

    while true; do
        # Run tools
        echo -e "${YELLOW}Select the tool you want to run:${NC}"
        echo "1) osv-scanner"
        echo "2) snyk cli"
        echo "3) brakeman Note: To scroll through pages press space, to exit the results page press q"
        echo "4) nmap"
        echo "5) nikto"
        echo "6) LEGION"
        echo "7) Run all"
        echo "8) Exit"
        read -p "Enter your choice (1/2/3/4/5/6/7/8): " choice

        case $choice in
            1)
                read -p "Enter directory to scan (current directory ./): " directory
                save_vulnerabilities "osv-scanner"
                ;;
            2)
                save_vulnerabilities "snyk"
                ;;
            3)
                save_vulnerabilities "brakeman"
                ;;
            4)
                read -p "Enter URL to scan: " url
                save_vulnerabilities "nmap"
                ;;
            5)
                read -p "Enter URL to scan: " url
                save_vulnerabilities "nikto"
                ;;
            6)
                read -p "Enter URL to scan: " url
                save_vulnerabilities "legion"
                ;;
            7)
                read -p "Enter directory to scan (current directory ./): " directory
                save_vulnerabilities "osv-scanner"
                save_vulnerabilities "snyk"
                save_vulnerabilities "brakeman"
                read -p "Enter URL to scan: " url
                save_vulnerabilities "nmap"
                read -p "Enter URL to scan: " url
                save_vulnerabilities "nikto"
                read -p "Enter URL to scan: " url
                save_vulnerabilities "legion"
                ;;
            8)
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
