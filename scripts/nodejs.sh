#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

if [ ! -f /usr/local/bin/node ]; then
    printf "${INFO}Installing Node.js...${RESET}\n"
    brew install node 2</dev/null >/dev/null
    printf "${SUCCESS}Node.js successfully installed.${RESET}\n\n"

    if [ -f /usr/local/bin/node ]; then
        printf "${SUCCESS}Node.js successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Node.js not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Node.js...${RESET}\n"
    brew upgrade node 2</dev/null >/dev/null
    printf "${SUCCESS}Node.js successfully upgraded.${RESET}\n\n"
fi

# Bower
./scripts/npm-packages/bower.sh