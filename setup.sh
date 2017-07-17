#!/usr/bin/env bash

# Thanks to https://github.com/mzdr

# Colors
RESET="\033[0m"
BOLD="\033[1m"
BRAND="${BOLD}\033[94m"
SUCCESS="\033[92m"
INFO="\033[94m"
WARNING="\033[93m"
DANGER="\033[91m"

# Directory
directory="$(cd "$(dirname "$0")" && pwd)"

# Keep-Alive for Sudo
while true
	do sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

count=1

# Header
header() {
	echo -e "\n${BRAND} $@ ${RESET}\n"
}

# Chapter
chapter() {
    echo -e "\n${BRAND} $((count++)). $@ ${RESET}\n"
}

# Step
step() {
    if [ $# -eq 1 ]
	    then
	        echo -e "${INFO} $@ ${RESET}"
	    else
	        echo -ne "${INFO} $@ ${RESET}"
    fi
}

# Welcome Message Screen
echo ""
header "                                                                              "
header "                                 Setup macOS                                  "
header "                                                                              "
header "                       We are about to pimp your  Mac!                       "
header "                   Follow the prompts and you’ll be fine. 👌                  "
header "                                                                              "
echo ""

# Quit System Prefences
# Prevents overriding preferences.
osascript -e 'tell application "System Preferences" to quit'

# Ask for Sudo Password
if [ $(sudo -n uptime 2>&1|grep "load" | wc -l) -eq 0 ]
then
	step "Some of these settings are system-wide, therefore we need your permission."
	sudo -v
fi

chapter "System Settings"

step "Setting your computer name."
echo -ne "  What would you like it to be? ${BOLD}"
read computer_name
echo -ne "${RESET}"
sudo scutil --set ComputerName "'${computer_name}'"
sudo scutil --set HostName "'${computer_name}'"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "'${computer_name}'"

chapter "Adjusting Mouse & Trackpad Settings"

step "Enable tap to click for this user and the login screen? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
		defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
		defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
		defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
		;;
esac

chapter "Adjusting App Store Settings"
step "Automatically check for updates? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
        ;;
esac

step "Download newly available updates in the background? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
        ;;
esac

step "Install system data files & security updates? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
        ;;
esac

step "Enable app auto-update? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        defaults write com.apple.commerce AutoUpdate -bool true
        ;;
esac

chapter "Adjusting Accessibility Settings"

step "Use scroll gesture with ^ Control modifier key to zoom? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
		defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
		defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
		;;
esac

chapter "Adjusting Finder Settings"

step "Keep folders on top when sorting by name? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
		defaults write com.apple.finder _FXSortFoldersFirst -bool true
		;;
esac

step "Enable AirDrop over ethernet? [Y/M]:" ""
case $(read choice; echo $choice) in
	[yY] )
        defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
        ;;
esac

step "Show the ~/Library folder? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        chflags nohidden ~/Library
        ;;
esac

step "Show the /Volumes folder? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        sudo chflags nohidden /Volumes
        ;;
esac

chapter "Setup Git"

if [ ! -f ~/.gitignore ]
	then
		step "Setting Git ignore."
		git clone https://gist.github.com/5a2a4e8f8a545cf25517a8578f65d1c2.git ${directory}/git-ignore 2>/dev/null &
		cp -n ${directory}/git-ignore/.gitignore ~/.gitignore
		git config --global core.excludesfile ~/.gitignore
		rm  -d -f -r ${directory}/git-ignore
fi

if [ ! -f ~/.gitconfig ]
	then
	step "Setting your name."
	echo -ne "  What is it? ${BOLD}"
	read name
	echo -ne "${RESET}"
	step "Setting your email."
	echo -ne "  What is it? ${BOLD}"
	read email
	echo -ne "${RESET}"
	git config --global user.name "${name}"
	git config --global user.email "${email}"
fi

chapter "Setup SSH"

if [ ! -f ~/.ssh/id_rsa ]
	then
		step "Setting your email."
		echo -ne "  What is it? ${BOLD}"
		read email
		echo -ne "${RESET}"
		ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "${email}"
		ssh-add ~/.ssh/id_rsa 2>/dev/null &
fi

step "Copy SSH key to clipboard? [Y/N]" ""
case $(read choice; echo $choice) in
	[yY] )
        pbcopy < ~/.ssh/id_rsa.pub
        ;;
esac

chapter "Software Update"

step "Update software? [Y/N]:" ""
case $(read choice; echo $choice) in
	[yY] )
        sudo softwareupdate -ia 2>/dev/null &
		sudo softwareupdate --schedule on 2>/dev/null &
        ;;
esac

chapter "Setup Xcode"

check=$(xcode-select --install 2>&1)
message="xcode-select: note: install requested for command line developer tools"
if [[ "${check}" != "${message}" ]]
	then
		choice="N"
		test="N"
		while [[ "${choice}" == "${test}" ]]
			do xcode-select --install 2>/dev/null &
			step "Xcode Installed? [Y/N]" ""
			read choice
		done
fi
xcodebuild -licensexc 2>/dev/null &

chapter "Install Apps & Packages"

step "Homebrew"
which -s brew
if [[ $? != 0 ]]
	then /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	brew update
fi

step "CLI Apps"
for app in $(<${directory}/apps/cli)
	do
	if ! brew list -1 | grep -q "^${app}\$"
		then brew install ${app}
		else brew upgrade ${app}
	fi
done

step "Desktop Apps"
for app in $(<${directory}/apps/desktop)
	do
	if ! brew cask list -1 | grep -q "^${app}\$"
		then brew install ${app}
		else brew upgrade ${app}
	fi
done

step "Game Apps"
for app in $(<${directory}/apps/game)
	do
	if ! brew cask list -1 | grep -q "^${app}\$"
		then brew install ${app}
		else brew upgrade ${app}
	fi
done

step "Browser Apps"
for app in $(<${directory}/apps/browser)
	do
	if ! brew cask list -1 | grep -q "^${app}\$"
		then brew install ${app}
		else brew upgrade ${app}
	fi
done

if ! brew list -1 | grep -q "^adobe-creative-cloud\$"
	step "Adobe Creative Cloud"
	then /usr/local/Caskroom/adobe-creative-cloud/latest/Creative\ Cloud\ Installer.app/Contents/MacOS/Install 2>/dev/null &
fi

if ! brew list -1 | grep -q "^node\$"
	step "NPM Packages"
	then
		for package in $(<${directory}/packages/npm)
			do
			if [ ! -f /usr/local/bin/${package} ]
				then npm install -g ${package} 2>/dev/null &
				else npm update -g ${package} 2>/dev/null &
			fi
		done
fi

step "Composer"
if [ ! -f /usr/local/bin/composer ]
	then
		expected_signature=$(wget -q -O - https://composer.github.io/installer.sig)
		actual_signature=""
		while [[ "${expected_signature}" != "${actual_signature}" ]]
			do
			php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
			actual_signature=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
		done
		php composer-setup.php --quiet
		php -r "unlink('composer-setup.php');"
		mv ./composer.phar /usr/local/bin/composer -n
		rm ./composer-setup.php -d -f
	else composer self-update -q
fi

step "Composer Packages"
for package in $(<${directory}/packages/composer)
	do
	if [ ! -d ~/.composer/vendor/${package} ]
		then composer global require ${package} --quiet
		else composer global update --quiet
	fi
done

step "PIP"
curl https://bootstrap.pypa.io/get-pip.py --output "get-pip.py" --silent
python get-pip.py 2>/dev/null &
rm -f ./get-pip.py

echo -e "${SUCCESS}macOS Setup${RESET}"