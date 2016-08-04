#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

if [ ! -f /usr/local/bin/cask ]; then
    printf "${INFO}Installing Cask...${RESET}\n"
    brew tap caskroom/cask 2</dev/null >/dev/null
    printf "${SUCCESS}Cask successfully installed.${RESET}\n\n"

    if [ -f /usr/local/bin/cask ]; then
        printf "${SUCCESS}Cask successfully installed.${RESET}\n\n"
    else
        printf "${DANGER}Cask not installed.${RESET}\n\n"
    fi
else
    printf "${INFO}Upgrading Cask...${RESET}\n"
    brew upgrade cask 2</dev/null >/dev/null
    brew tap caskroom/cask 2</dev/null >/dev/null
    printf "${SUCCESS}Cask successfully upgraded.${RESET}\n\n"
fi

# Adobe
./scripts/homebrew-packages/casks/adobe.sh

# Aerial
./scripts/homebrew-packages/casks/aerial.sh

# CleanMyMac
./scripts/homebrew-packages/casks/cleanmymac.sh

# CrashPlan
./scripts/homebrew-packages/casks/crashplan.sh

# Discord
./scripts/homebrew-packages/casks/discord.sh

# Dropbox
./scripts/homebrew-packages/casks/dropbox.sh

# Dymo
./scripts/homebrew-packages/casks/dymo.sh

# Google Chrome
#./scripts/homebrew-packages/casks/google-chrome.sh

# Grammarly
./scripts/homebrew-packages/casks/grammarly.sh

# JetBrains
./scripts/homebrew-packages/casks/jetbrains.sh

# MAMP
./scripts/homebrew-packages/casks/mamp.sh

# Panic
./scripts/homebrew-packages/casks/panic.sh

# RescueTime
./scripts/homebrew-packages/casks/rescuetime.sh

# Skype
./scripts/homebrew-packages/casks/skype.sh

# VirtualBox
./scripts/homebrew-packages/casks/virtualbox.sh