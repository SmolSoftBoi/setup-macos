#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Dropbox
if [ ! -d /usr/local/Caskroom/dropbox ]; then
    printf "${INFO}Installing Dropbox...${RESET}\n"
    brew cask install dropbox 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/dropbox ]; then
        printf "${SUCCESS}Dropbox successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Dropbox not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Dropbox...${RESET}\n"
    brew cask upgrade dropbox 2</dev/null >/dev/null
    printf "${SUCCESS}Dropbox successfully upgraded.${RESET}\n\n"
fi