#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

# Install VirtualBox guest additions
echo -e "${BYellow}[ * ]Install VirtualBox guest additions${End_Colour}"
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice.service
sudo usermod -a -G vboxsf $USER

echo -e "${BGreen}Setup Completed !! Reboot Your Machine${End_Colour}"