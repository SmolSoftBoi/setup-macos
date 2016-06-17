#!/usr/bin/env bash

# Colors
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_RESET="\033[0m"

# Install composer
if [ ! -f /usr/local/bin/composer ]; then
    printf "${COLOR_YELLOW}Installing composer...${COLOR_RESET}\n"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --quiet
    php -r "unlink('composer-setup.php');"
    mv composer.phar /usr/local/bin/composer
    printf "${COLOR_GREEN}Composer successfully installed.${COLOR_RESET}\n\n"
else
    printf "${COLOR_YELLOW}Updating composer...${COLOR_RESET}\n"
    composer self-update -q
    printf "${COLOR_GREEN}Composer successfully updated.${COLOR_RESET}\n\n"
fi