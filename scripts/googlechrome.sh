#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Google Chrome
if [ ! -d /usr/local/Caskroom/google-chrome ]; then
    printf "${INFO}Installing Google Chrome...${RESET}\n"
    brew cask install google-chrome 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/google-chrome ]; then
        printf "${SUCCESS}Google Chrome successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Google Chrome not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Google Chrome...${RESET}\n"
    brew cask upgrade google-chrome 2</dev/null >/dev/null
    printf "${SUCCESS}Google Chrome successfully upgraded.${RESET}\n\n"
fi