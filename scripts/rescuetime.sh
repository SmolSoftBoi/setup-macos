#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install RescueTime
if [ ! /usr/local/Caskroom/composer ]; then
    printf "${INFO}Installing RescueTime...${RESET}\n"
    brew cask install rescuetime 2</dev/null >/dev/null

    if [ /usr/local/Caskroom/composer ]; then
        printf "${SUCCESS}RescueTime successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}RescueTime not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading RescueTime...${RESET}\n"
    brew cask upgrade rescuetime 2</dev/null >/dev/null
    printf "${SUCCESS}RescueTime successfully upgraded.${RESET}\n\n"
fi