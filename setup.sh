#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Welcome message
printf "\n${BRAND}Setup macOS${RESET}\n\n"

printf "${INFO}Setting up macOS${BLINK}...${RESET}\n\n"

printf "${INFO}"
sudo -v
printf "${RESET}\n"

# Xcode
./scripts/xcode.sh

# SSH
./scripts/ssh.sh

# Composer
./scripts/composer.sh

# Homebrew
./scripts/homebrew.sh

# Node.js
./scripts/nodejs.sh

# Cask
./scripts/cask.sh

printf "${SUCCESS}macOS setup.${RESET}\n\n"