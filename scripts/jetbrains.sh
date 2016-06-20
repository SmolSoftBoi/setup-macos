#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install JetBrains Toolbox
if [ ! -d /usr/local/Caskroom/jetbrains-toolbox ]; then
    printf "${INFO}Installing Jetbrains Toolbox...${RESET}\n"
    brew cask install jetbrains-toolbox 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/jetbrains-toolbox ]; then
        printf "${SUCCESS}Jetbrains Toolbox successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Jetbrains Toolbox not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Jetbrains Toolbox...${RESET}\n"
    brew cask upgrade jetbrains-toolbox 2</dev/null >/dev/null
    printf "${SUCCESS}Jetbrains Toolbox successfully upgraded.${RESET}\n\n"
fi