#!/usr/bin/env bash

# Colors
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_RESET="\033[0m"

if [ ! -f ~/.ssh/id_rsa ]; then
    printf "${COLOR_YELLOW}Setting up SSH key...${COLOR_RESET}\n"
    printf "${COLOR_YELLOW}Email:${COLOR_RESET} "
    read email

    ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "${email}"
    ssh-add ~/.ssh/id_rsa 2>/dev/null
    printf "${COLOR_GREEN}SSH key setup.${COLOR_RESET}\n"
fi

pbcopy < ~/.ssh/id_rsa.pub
printf "${COLOR_GREEN}SSH key copied to clipboard.${COLOR_RESET}\n\n"