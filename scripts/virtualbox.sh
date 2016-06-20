#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install VirtualBox
if [ ! -d /usr/local/Caskroom/virtualbox ]; then
    printf "${INFO}Installing VirtualBox...${RESET}\n"
    brew cask install virtualbox 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/virtualbox ]; then
        printf "${SUCCESS}VirtualBox successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}VirtualBox not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading VirtualBox...${RESET}\n"
    brew cask upgrade virtualbox 2</dev/null >/dev/null
    printf "${SUCCESS}VirtualBox successfully upgraded.${RESET}\n\n"
fi