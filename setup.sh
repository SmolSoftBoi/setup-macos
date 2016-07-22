#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Welcome message
printf "\n${BRAND}Setup macOS${RESET}\n\n"

printf "${INFO}Setting up macOS...${RESET}\n\n"

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

# Bower
./scripts/bower.sh

# Cask
./scripts/cask.sh

# Adobe
./scripts/adobe.sh

# CleanMyMac
./scripts/cleanmymac.sh

# CrashPlan
./scripts/crashplan.sh

# Discord
./scripts/discord.sh

# Dropbox
./scripts/dropbox.sh

# Dymo
./scripts/dymo.sh

# Google Chrome
#./scripts/googlechrome.sh

# JetBrains
./scripts/jetbrains.sh

# MAMP
./scripts/mamp.sh

# Panic
./scripts/panic.sh

# RescueTime
./scripts/rescuetime.sh

# Skype
./scripts/skype.sh

# VirtualBox
./scripts/virtualbox.sh

printf "${SUCCESS}macOS setup.${RESET}\n\n"