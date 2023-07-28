#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

# Install graphical environment and i3
echo -e "${BYellow}[ * ]Install graphical environment and i3${End_Colour}"
sudo pacman -S xorg-server xorg-apps xorg-xinit
sudo pacman -S i3-gaps i3blocks i3lock i3status numlockx

# Install display manager
echo -e "${BYellow}[ * ]Install display manager${End_Colour}"
sudo pacman -S lightdm lightdm-gtk-greeter --needed
sudo systemctl enable lightdm

# Install some basic fonts
echo -e "${BYellow}[ * ]Install some basic fonts${End_Colour}"
sudo pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont
sudo pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font

# Install some useful tools on i3
echo -e "${BYellow}[ * ]Install some useful tools on i3${End_Colour}"
sudo pacman -S rxvt-unicode ranger rofi dmenu --needed

# Install some GUI programs
echo -e "${BYellow}[ * ]Install some GUI programs${End_Colour}"
sudo pacman -S firefox vlc obsidian --needed

# Install zsh
echo -e "${BYellow}[ * ]Install zsh${End_Colour}"
sudo pacman -S zsh
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Copy i3 config file
echo -e "${BYellow}[ * ]Copy i3 config file${End_Colour}"
mkdir ~/.config/i3
cp .config/i3/config ~/.config/i3/config

echo -e "${BGreen}Setup Completed !! Reboot Your Machine${End_Colour}"