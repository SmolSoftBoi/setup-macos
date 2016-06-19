#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Setup Xcode
xcode-select --install 2</dev/null >/dev/null
xcodebuild -licensexc 2</dev/null >/dev/null