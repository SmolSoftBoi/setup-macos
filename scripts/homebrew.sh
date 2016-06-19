#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install homebrew
if [ ! -f /usr/local/bin/brew ]; then
    printf "${INFO}Installing Homebrew...${RESET}\n"
    yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \ 2</dev/null >/dev/null
    brew install wget 2</dev/null >/dev/null
    brew tap Homebrew/bundle 2</dev/null >/dev/null

    if [ ! -f /usr/local/bin/brew ]; then
        printf "${SUCCESS}Homebrew successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Homebrew not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Updating Homebrew...${RESET}\n"
    brew update 2</dev/null >/dev/null
    printf "${SUCCESS}Homebrew successfully updated.${RESET}\n\n"
fi