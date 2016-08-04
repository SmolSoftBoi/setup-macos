#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Aerial
if [ ! -d /usr/local/Caskroom/aerial ]; then
    printf "${INFO}Installing Aerial...${RESET}\n"
    brew cask install aerial 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/aerial ]; then
        printf "${SUCCESS}Aerial successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Aerial not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Aerial...${RESET}\n"
    brew cask upgrade aerial 2</dev/null >/dev/null
    /usr/local/Caskroom/aerial 2</dev/null >/dev/null
    printf "${SUCCESS}Aerial successfully upgraded.${RESET}\n\n"
fi