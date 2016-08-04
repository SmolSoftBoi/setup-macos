#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

if [ ! -f /usr/local/bin/bower ]; then
    printf "${INFO}Installing Bower...${RESET}\n"
    npm install -g bower 2</dev/null >/dev/null
    printf "${SUCCESS}Bower successfully installed.${RESET}\n\n"

    if [ -f /usr/local/bin/bower ]; then
        printf "${SUCCESS}Bower successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Bower not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Updating Bower...${RESET}\n"
    npm update -g bower 2</dev/null >/dev/null
    printf "${SUCCESS}Bower successfully updated.${RESET}\n\n"
fi