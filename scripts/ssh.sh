#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Setup SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    printf "${INFO}Setting up SSH key...${RESET}\n"
    printf "${INFO}Email:${RESET} "
    read email

    ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "${email}"
    ssh-add ~/.ssh/id_rsa 2</dev/null >/dev/null

    if [ -f ~/.ssh/id_rsa ]; then
        printf "${SUCCESS}SSH key setup.${RESET}\n"
    else
        printf "${DANGER}SSH key not setup.${RESET}\n"
    fi
fi

# Copy SSH key
pbcopy < ~/.ssh/id_rsa.pub
printf "${SUCCESS}SSH key copied to clipboard.${RESET}\n\n"