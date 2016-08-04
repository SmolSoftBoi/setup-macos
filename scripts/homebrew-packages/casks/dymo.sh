#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Dymo
if [ ! -d /usr/local/Caskroom/dymo-label ]; then
    printf "${INFO}Installing Dymo...${RESET}\n"
    brew cask install dymo-label 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/dymo-label ]; then
        printf "${SUCCESS}Dymo successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Dymo not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Dymo...${RESET}\n"
    brew cask upgrade dymo-label 2</dev/null >/dev/null
    printf "${SUCCESS}Dymo successfully upgraded.${RESET}\n\n"
fi