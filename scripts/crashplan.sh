#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install CrashPlan
if [ ! -d /usr/local/Caskroom/crashplan ]; then
    printf "${INFO}Installing CrashPlan...${RESET}\n"
    brew cask install crashplan 2</dev/null >/dev/null

    if [ -d /usr/local/Caskroom/crashplan ]; then
        printf "${SUCCESS}CrashPlan successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}CrashPlan not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading CrashPlan...${RESET}\n"
    brew cask upgrade crashplan 2</dev/null >/dev/null
    printf "${SUCCESS}CrashPlan successfully upgraded.${RESET}\n\n"
fi