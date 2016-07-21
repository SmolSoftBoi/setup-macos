#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Transmit
if [ ! -d /usr/local/Caskroom/transmit ]; then
    printf "${INFO}Installing Transmit...${RESET}\n"
    brew cask install transmit 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/transmit ]; then
        printf "${SUCCESS}Transmit successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Transmit not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Transmit...${RESET}\n"
    brew cask upgrade transmit 2</dev/null >/dev/null
    printf "${SUCCESS}Transmit successfully upgraded.${RESET}\n\n"
fi