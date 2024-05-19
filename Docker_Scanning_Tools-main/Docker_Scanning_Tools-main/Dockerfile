# Use the official Debian base image
FROM kalilinux/kali-rolling:latest

#Create directory for Script
WORKDIR /app

#Create directory for Output files
RUN mkdir /home/kali

# Update the package repository
RUN apt-get update 
RUN apt-get install -y

#Install dependencies
RUN apt-get install -y curl wget git gpg golang-go sudo gcc dos2unix rubygems-integration ruby-dev

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install -y nodejs

# Install Nmap    
RUN apt-get install -y nmap

# Verify that Node.js was installed
RUN node -v
RUN npm -v

# Install osv_scaner
RUN go install github.com/google/osv-scanner/cmd/osv-scanner@v1

#Set up and run the tool script
COPY tools.sh /app/
RUN chmod +x /app/tools.sh
RUN dos2unix /app//tools.sh

# Add alias for the script
RUN echo 'alias scan1="/app/tools.sh"' >> ~/.bashrc

# Set the working directory
WORKDIR /home/kali

# Set an entry point (optional)
# ENTRYPOINT ["nmap"]
# You can add any other instructions or configurations here
# Add a CMD instruction
ENTRYPOINT ["/app/tools.sh"]