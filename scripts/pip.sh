#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

# Install pip
printf "${INFO}Installing pip...${RESET}\n"
curl https://bootstrap.pypa.io/get-pip.py --output "get-pip.py" --silent
python get-pip.py 2</dev/null >/dev/null
rm ./get-pip.py -d -f
printf "${SUCCESS}pip successfully installed.${RESET}\n\n"