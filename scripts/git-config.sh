#!/usr/bin/env bash

RESET="\033[0m"
BRAND="\033[1;34m"
INFO="\033[33m"
SUCCESS="\033[32m"
DANGER="\033[31m"

if [ ! -f ~/.gitignore ]; then
	printf "${INFO}Setting up git ignore...${RESET}\n"
	cp -n ./configs/.gitignore ~/.gitignore
	touch ~/.gitignore
	git config --global core.excludesfile ~/.gitignore

	if [ -f ~/.gitignore ]; then
        printf "${SUCCESS}Git ignore successfully setup.${RESET}\n\n"
    else
        printf "${DANGER}Git ignore not setup.${RESET}\n\n"
    fi
fi

if [ ! -f ~/.gitconfig ]; then
	printf "${INFO}Setting up git configuration...${RESET}\n"
	printf "${INFO}Name:${RESET} "
    read name
    printf "${INFO}Email:${RESET} "
    read email

    git config --global user.name "{$name}"
    git config --global user.email "{$email}"

    if [ -f ~/.gitconfig ]; then
    	printf "${SUCCESS}Git configuration successfully setup.${RESET}\n\n"
    else
    	printf "${DANGER}Git configuration not setup.${RESET}\n\n"
    fi
fi