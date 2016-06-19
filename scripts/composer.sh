#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install composer
if [ ! -f /usr/local/bin/composer ]; then
    printf "${INFO}Installing composer...${RESET}\n"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --quiet
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer

    if [ ! -f /usr/local/bin/composer ]; then
        printf "${SUCCESS}Composer successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Composer not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Updating composer...${RESET}\n"
    composer self-update -q
    printf "${SUCCESS}Composer successfully updated.${RESET}\n\n"
fi