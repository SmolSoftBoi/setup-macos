#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install MAMP
if [ ! -d /usr/local/Caskroom/mamp ]; then
    printf "${INFO}Installing MAMP...${RESET}\n"
    brew cask install mamp 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/mamp ]; then
        printf "${SUCCESS}MAMP successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}MAMP not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading MAMP...${RESET}\n"
    brew cask upgrade mamp 2</dev/null >/dev/null
    printf "${SUCCESS}MAMP successfully upgraded.${RESET}\n\n"
fi