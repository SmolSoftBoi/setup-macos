#!/usr/bin/env bash

# Colors
COLOR_RESET="\033[0m"
COLOR_BLUE="\033[0;34m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"

# Welcome message
printf "\n${COLOR_BLUE}Setup macOS${COLOR_RESET}\n\n"

printf "${COLOR_YELLOW}Setting up macOS...${COLOR_RESET}\n\n"

# Xcode
#./scripts/xcode.sh

# Composer
./scripts/composer.sh

# SSH
./scripts/ssh.sh

printf "${COLOR_GREEN}macOS setup.${COLOR_RESET}\n\n"