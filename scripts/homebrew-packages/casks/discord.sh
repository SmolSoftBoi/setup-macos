#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Discord
if [ ! -d /usr/local/Caskroom/discord ]; then
    printf "${INFO}Installing Discord...${RESET}\n"
    brew cask install discord 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/discord ]; then
        printf "${SUCCESS}Discord successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Discord not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Discord...${RESET}\n"
    brew cask upgrade discord 2</dev/null >/dev/null
    printf "${SUCCESS}Discord successfully upgraded.${RESET}\n\n"
fi