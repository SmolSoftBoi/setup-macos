#!/usr/bin/env bash#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install PHP Mess Detected
if [ ! -d ~/.composer/vendor/phpmd/phpmd ]; then
    printf "${INFO}Installing PHP Mess Detector...${RESET}\n"
    composer global require phpmd/phpmd --quiet

    if [ -d ~/.composer/vendor/phpmd/phpmd ]; then
        printf "${SUCCESS}PHP Mess Detector successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}PHP Mess Detector not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading PHP Mess Detector...${RESET}\n"
    composer global update --quiet
    printf "${SUCCESS}PHP Mess Detector successfully upgraded.${RESET}\n\n"
fi