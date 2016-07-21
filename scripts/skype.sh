#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Skype
if [ ! -d /usr/local/Caskroom/skype ]; then
    printf "${INFO}Installing Skype...${RESET}\n"
    brew cask install skype 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/skype ]; then
        printf "${SUCCESS}Skype successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Skype not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Skype...${RESET}\n"
    brew cask upgrade skype 2</dev/null >/dev/null
    printf "${SUCCESS}Skype successfully upgraded.${RESET}\n\n"
fi