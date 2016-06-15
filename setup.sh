#!/usr/bin/env bash

# Colors
COLOR_RESET="\033[0m"
COLOR_BLUE="\033[0;34m"
COLOR_GREEN="\033[0;32m"
COLOR_ORANGE="\033[0;33m"

# Welcome message
echo -e "\n${COLOR_BLUE}Setup macOS${COLOR_RESET}\n"

confirm_install () {
	echo -e "Install $1? [${COLOR_ORANGE}Y${COLOR_RESET}/${COLOR_ORANGE}N${COLOR_RESET}]"
	read -s confirm;

	case ${confirm} in
		[Yn]* ) return 0;;
		[Nn]* ) return 1;;
	esac
}

# Xcode
#./scripts/xcode.sh

# Composer
if confirm_install "composer"; then
	./scripts/composer.sh
fi