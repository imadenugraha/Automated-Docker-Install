#!/bin/bash
# Author: Moonliez
# Version: v1.7
# Description: Automated Docker Install on Ubuntu

function install_docker() {

    # Create variable to custom echo colors
    GREEN='\033[1;32m'
    RED='\033[1;31m'
    CLEAR='\033[0m'

    # Disable docker.service and docker.socket and prevent to running
    echo -e "$GREEN[*] Disable and stoping Docker$CLEAR\n"

    STATUS="$(systemctl show docker.service --no-page)";
    STATUS_TEXT="$(echo "$STATUS" | grep "ActiveState=" | cut -f2 -d=)";

    if [[ "$STATUS_TEXT" == "active" ]];
    then
        sudo systemctl disable --now docker.service
        sudo systemctl disable --now docker.socket
    else
        echo -e "$GREEN[*] No Docker is Running$CLEAR\n"
    fi

    # Removing old version of docker engines
    echo -e "$GREEN[*] Removing Docker old version$CLEAR"
    
    SERVICE="docker"

    if [[ -f "/etc/init.d/$SERVICE" ]]; 
    then
        sudo apt-get -y remove docker docker-ce-cli docker-engine docker.io containerd runc docker-compose-plugin docker-compose;
        sudo apt-get -y autoremove
        echo -e "$GREEN[*] Remove success!$CLEAR\n"
    else
        echo -e "$GREEN[*] Docker not exist, skipping...$CLEAR\n"
    fi

    # Setup docker repository for ubuntu
    echo -e "$GREEN[*] Set up the repository$CLEAR"
    
    if [[ $(sudo apt-get update) = 1 ]];
    then
        echo -e "$RED[*] Update failed, please check your system...$CLEAR\n"
        echo -e "$RED[*] DOCKER INSTALL FAILED!$CLEAR"
        exit 1;
    else
        sudo apt-get -y install ca-certificates curl gnupg lsb-release;
    fi

    FILE=/etc/apt/keyrings/docker.gpg;
    if [[ -f "$FILE" ]];
    then
        echo -e "$GREEN[*] File $FILE exist, skipping...$CLEAR\n"
    else 
        sudo mkdir -p /etc/apt/keyrings;
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg;
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
        echo -e "$GREEN[*] Set up success!$CLEAR\n"
    fi

    # Install Docker Engine and Dependencies
    echo -e "$GREEN[*] Install Docker Engine$CLEAR"
    
    if [[ $(sudo apt-get update) = 1 ]];
    then
        echo -e "$RED[*] Update failed, please check your system...$CLEAR\n"
        echo -e "$RED[*] DOCKER INSTALL FAILED!$CLEAR"
        exit 1;
    else  
        sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose;
        echo -e "$GREEN[*] Install Success!$CLEAR\n"
    fi

    # Starting Docker Service 
    echo -e "$GREEN[*] Starting Docker$CLEAR"
    sudo systemctl enable --now docker.service;
    sudo systemctl start docker.service;
    echo -e "$GREEN[*] Docker Started!\n$CLEAR"

    # Configure docker to run rootless
    echo -e "$GREEN[*] Configure Docker Rootless$CLEAR"
    sudo usermod -aG docker $USER;
    echo ""

    echo -e "$GREEN[*] DOCKER INSTALLED SUCCESSFULLY!$CLEAR"
    echo -e "$GREEN[*] Reboot is necessary to run docker on rootless mode!$CLEAR"

    exit 0;
}

# Call main function
install_docker
