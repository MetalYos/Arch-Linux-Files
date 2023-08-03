#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

# Install graphical environment and i3
echo -e "${BYellow}[ * ]Install graphical environment and i3${End_Colour}"
sudo pacman -S xorg-server xorg-apps xorg-xinit  --noconfirm
sudo pacman -S i3-gaps i3blocks i3lock i3status numlockx  --noconfirm

# Install display manager
echo -e "${BYellow}[ * ]Install display manager${End_Colour}"
sudo pacman -S lightdm lightdm-gtk-greeter --needed  --noconfirm
sudo systemctl enable lightdm

# Install some basic fonts
echo -e "${BYellow}[ * ]Install some basic fonts${End_Colour}"
sudo pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont  --noconfirm
sudo pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font  --noconfirm

# Install some useful tools on i3
echo -e "${BYellow}[ * ]Install some useful tools on i3${End_Colour}"
sudo pacman -S rxvt-unicode ranger rofi dmenu --needed  --noconfirm

# Install some GUI programs
echo -e "${BYellow}[ * ]Install some GUI programs${End_Colour}"
sudo pacman -S firefox vlc --needed  --noconfirm

# Install zsh
echo -e "${BYellow}[ * ]Install zsh${End_Colour}"
sudo pacman -S zsh git  --noconfirm
echo Y exit | sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install LX LXAppearance and themes
echo -e "${BYellow}[ * ]Install LX LXAppearance and themes${End_Colour}"
sudo pacman -S lxappearance arc-gtk-theme papirus-icon-theme --noconfirm

# Customize LightDM
echo -e "${BYellow}[ * ]Customize LightDM${End_Colour}"
sudo sed -i 's/#background=/background=#2f343f/g' /etc/lightdm/lightdm-gtk-greeter.conf
sudo sed -i 's/#icon-theme-name=/icon-theme-name=Papirus-Dark/g' /etc/lightdm/lightdm-gtk-greeter.conf
sudo sed -i 's/#theme-name=/theme-name=Arc-Dark/g' /etc/lightdm/lightdm-gtk-greeter.conf

# Copy i3 config file
echo -e "${BYellow}[ * ]Copy i3 config file${End_Colour}"
mkdir /home/yossi/.config/i3
cp .config/i3/config /home/yossi/.config/i3/config

echo -e "${BGreen}i3 Setup Completed!!${End_Colour}"