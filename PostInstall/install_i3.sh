#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

username=${1}

# Install graphical environment and i3
echo -e "${BYellow}[ * ]Install graphical environment and i3${End_Colour}"
pacman -S xorg-server xorg-apps xorg-xinit --noconfirm
pacman -S i3-gaps i3blocks i3lock i3status numlockx --noconfirm

# Install display manager
echo -e "${BYellow}[ * ]Install display manager${End_Colour}"
pacman -S lightdm lightdm-gtk-greeter --needed --noconfirm
systemctl enable lightdm

# Install some basic fonts
echo -e "${BYellow}[ * ]Install some basic fonts${End_Colour}"
pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont --noconfirm
pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font --noconfirm

# Install some useful tools on i3
echo -e "${BYellow}[ * ]Install some useful tools on i3${End_Colour}"
pacman -S kitty ranger rofi dmenu --needed --noconfirm

# Install some GUI programs
echo -e "${BYellow}[ * ]Install some GUI programs${End_Colour}"
pacman -S firefox vlc --needed --noconfirm

# Install zsh
echo -e "${BYellow}[ * ]Install zsh${End_Colour}"
pacman -S zsh git --noconfirm
echo Y exit | sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install LX LXAppearance and themes
echo -e "${BYellow}[ * ]Install LX LXAppearance and themes${End_Colour}"
pacman -S lxappearance arc-gtk-theme papirus-icon-theme --noconfirm

# Customize LightDM
echo -e "${BYellow}[ * ]Customize LightDM${End_Colour}"
sed -i 's/#background=/background=#2f343f/g' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#icon-theme-name=/icon-theme-name=Papirus-Dark/g' /etc/lightdm/lightdm-gtk-greeter.conf
sed -i 's/#theme-name=/theme-name=Arc-Dark/g' /etc/lightdm/lightdm-gtk-greeter.conf

# Install Kitty themes
echo -e "${BYellow}[ * ]Install Kitty themes${End_Colour}"
git clone --depth 1 https://github.com/dexpota/kitty-themes.git /home/${username}/.config/kitty/kitty-themes
ln -s /home/${username}/.config/kitty/kitty-themes/themes/Dracula.conf /home/${username}/.config/kitty/theme.conf
echo "include ./theme.conf" > /home/${username}/.config/kitty/kitty.conf

echo -e "${BGreen}i3 Setup Completed!!${End_Colour}"