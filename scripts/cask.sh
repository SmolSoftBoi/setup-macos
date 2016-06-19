#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

if [ ! -f /usr/local/bin/cask ]; then
    printf "${INFO}Installing Cask...${RESET}\n"
    brew tap caskroom/cask 2</dev/null >/dev/null
    printf "${SUCCESS}Cask successfully installed.${RESET}\n\n"

    if [ -f /usr/local/bin/cask ]; then
        printf "${SUCCESS}Cask successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Cask not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Cask...${RESET}\n"
    brew upgrade cask 2</dev/null >/dev/null
    brew tap caskroom/cask 2</dev/null >/dev/null
    printf "${SUCCESS}Cask successfully upgraded.${RESET}\n\n"
fi