#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
BBlue="\e[1;34m"
End_Colour="\e[0m"

username=${1}
password=${2}

function InstallAurHelper() {
	echo -e "${BYellow}[ * ]Install the YAY AUR helper${End_Colour}"
	cur_dir=`pwd`
	cd /home/${username}/Downloads
	echo "${password}" | sudo -S pacman -S git --noconfirm
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd ..
	rm -Rf yay
	cd ${cur_dir}
}

function InstallAdditionalPackages() {
	# Install other useful packages
	echo -e "${BYellow}[ * ]Install useful packages${End_Colour}"
	echo "${password}" | sudo -S pacman-key --init
	echo "${password}" | sudo -S pacman -S timeshift dosfstools ntfs-3g iw wpa_supplicant dialog intel-ucode lshw unzip htop wget openssh git gdb valgrind man tldr stow bash-completion reflector mpv fastfetch transmission-gtk meld tmux --noconfirm
}

function InstallAdditionalAurPackages() {
	echo -e "${BYellow}[ * ]Install useful AUR packages${End_Colour}"
	yay -S timeshift-autosnap sioyek amberol --noconfirm
}

function EnableAutoUsbMounting() {
	# Install udisks and enable auto USB mounting
	echo -e "${BYellow}[ * ]Install udisks and enable USB storage automounting${End_Colour}"
	echo "${password}" | sudo -S pacman-key --init
	echo "${password}" | sudo -S pacman -S udisks2 udiskie --noconfirm

	echo -e "${BYellow}[ * ]Copying polkit rule for USB storage automounting${End_Colour}"
	cur_dir=`pwd`
	cd /PostInstall
	cp 10-udisks2.rules /etc/polkit-1/rules.d/
	cd ${cur_dir}
}

function InstallPipewireAudio() {
	echo -e "${BYellow}[ * ]Install Pipewire packages${End_Colour}"

	# Install all relevant Pipewrire packages
	echo "${password}" | sudo -S pacman -Syu pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack lib32-pipewire-jack dkms sof-firmware volumeicon alsa-utils --noconfirm

	echo -e "${BYellow}[ * ]Enable Pipewire user units${End_Colour}"
	systemctl --user enable pipewire.socket
	systemctl --user enable pipewire-pulse.socket
	systemctl --user enable wireplumber.service
	echo -e "${BYellow}[ * ]Install the YAY AUR helper${End_Colour}"
}

function InstallDisplayServer() {
	echo -e "${BYellow}[ * ]Install X11 display server${End_Colour}"
	echo "${password}" | sudo -S pacman -S xorg-server xorg-apps xorg-xinit --noconfirm
}

function InstallDisplayManager() {
	echo -e "${BYellow}[ * ]Install SDDM display manager${End_Colour}"
	echo "${password}" | sudo -S pacman -S sddm qt6-5compat qt6-declarative qt6-svg --noconfirm
	sudo systemctl enable sddm.service

	echo -e "${BYellow}[ * ]Copy default sddm config file to local folder${End_Colour}"
	echo "${password}" | sudo -S mkdir -p /etc/sddm.conf.d
	echo "${password}" | sudo -S cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf.d/sddm.conf

	echo -e "${BYellow}[ * ]Install SDDM Astronaut theme manager${End_Colour}"
	echo "${password}" | sudo -S git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
	echo "${password}" | sudo -S cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
	echo "${password}" | sudo -S sed -i "s/FullBlur=\"false\"/FullBlur=\"true\"/g" /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf
	echo "${password}" | sudo -S sed -i "s/PartialBlur=\"true\"/PartialBlur=\"false\"/g" /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf
	echo "${password}" | sudo -S sed -i "s/BlurRadius=\"80\"/BlurRadius=\"20\"/g" /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf
	echo "${password}" | sudo -S sed -i "s/Current=/Current=sddm-astronaut-theme/g" /etc/sddm.conf.d/sddm.conf
}

function Installi3() {
	echo -e "${BYellow}[ * ]Install i3 window manager${End_Colour}"
	echo "${password}" | sudo -S pacman -S i3-gaps i3blocks i3lock i3status numlockx xss-lock polybar --noconfirm

	# Install some basic fonts
	echo -e "${BYellow}[ * ]Install some basic fonts${End_Colour}"
	echo "${password}" | sudo -S pacman -S ttf-cascadia-code noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont --noconfirm
	echo "${password}" | sudo -S pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font --noconfirm

	# Install needed application
	echo -e "${BYellow}[ * ]Install extra applications for the i3 window manager${End_Colour}"
	echo "${password}" | sudo -S pacman -S alacritty keepass ranger rofi thunderbird obsidian picom feh --noconfirm
	yay -S brave-bin --noconfirm
}

function InstallAuthenticationAgent() {
	echo "${password}" | sudo -S pacman -S polkit-gnome --noconfirm
}

function InstallNotificationServer() {
	echo -e "${BYellow}[ * ]Notification Server for window manager${End_Colour}"
	echo "${password}" | sudo -S pacman -S libnotify notification-daemon --noconfirm

	cur_dir=`pwd`
	cd /PostInstall
	echo "${password}" | sudo -S cp org.freedesktop.Notification.service /usr/share/dbus-1/services/
	cd ${cur_dir}
}

function InstallNeovim() {
	echo -e "${BYellow}[ * ]Install Neovim and other needed packages${End_Colour}"
	echo "${password}" | sudo -S pacman -S neovim luarocks pyright xclip npm cargo python-pip ripgrep fd lazygit --noconfirm
}

function CopyConfigFiles() {
	echo -e "${BYellow}[ * ]Copying relevant config files${End_Colour}"
	cur_dir=`pwd`
	cd /home/${username}
	git clone https://github.com/metalyos/dotfiles.git
	cd dotfiles
	stow . --adopt

	cd /PostInstall
	sudo cp 40-libinput.conf /etc/X11/xorg.conf.d/
	cd ${cur_dir}
}

function SetupGitConfig() {
	# TODO: get values in installation script
	git config --global user.email "metalyos@gmail.com"
	git config --global user.name "MetalYos"
}

function Main() {
	echo -e "${BYello}[ * ]Entered user_post_install script with arguments ${username} ${password}${End_Colour}"
	InstallAurHelper
	EnableAutoUsbMounting
	InstallPipewireAudio
	InstallDisplayServer
	InstallDisplayManager
	Installi3
	InstallAuthenticationAgent
	InstallNotificationServer
	InstallAdditionalPackages
	InstallAdditionalAurPackages
	InstallNeovim
	CopyConfigFiles

	SetupGitConfig
}

Main "$@"
