#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install CleanMyMac
if [ ! -d /usr/local/Caskroom/cleanmymac ]; then
    printf "${INFO}Installing CleanMyMac...${RESET}\n"
    brew cask install cleanmymac 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/cleanmymac ]; then
        printf "${SUCCESS}CleanMyMac successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}CleanMyMac not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading CleanMyMac...${RESET}\n"
    brew cask upgrade cleanmymac 2</dev/null >/dev/null
    printf "${SUCCESS}CleanMyMac successfully upgraded.${RESET}\n\n"
fi