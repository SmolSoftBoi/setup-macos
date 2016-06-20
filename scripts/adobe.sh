#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install Adobe Creative Cloud
if [ ! -d /usr/local/Caskroom/adobe-creative-cloud ]; then
    printf "${INFO}Installing Adobe Creative Cloud...${RESET}\n"
    brew cask install adobe-creative-cloud 2</dev/null >/dev/null
    /usr/local/Caskroom/adobe-creative-cloud/latest/Creative\ Cloud\ Installer.app/Contents/MacOS/Install 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/adobe-creative-cloud ]; then
        printf "${SUCCESS}Adobe Creative Cloud successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Adobe Creative Cloud not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Adobe Creative Cloud...${RESET}\n"
    brew cask upgrade adobe-creative-cloud 2</dev/null >/dev/null
    /usr/local/Caskroom/adobe-creative-cloud/latest/Creative\ Cloud\ Installer.app/Contents/MacOS/Install 2</dev/null >/dev/null
    printf "${SUCCESS}Adobe Creative Cloud successfully upgraded.${RESET}\n\n"
fi