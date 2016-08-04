#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Grammarly
if [ ! -d /usr/local/Caskroom/grammarly ]; then
    printf "${INFO}Installing Grammarly...${RESET}\n"
    brew cask install grammarly 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/grammarly ]; then
        printf "${SUCCESS}Grammarly successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Grammarly not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Grammarly...${RESET}\n"
    brew cask upgrade grammarly 2</dev/null >/dev/null
    printf "${SUCCESS}Grammarly successfully upgraded.${RESET}\n\n"
fi