#!/bin/bash

# Before running this script you need to run the following commands manually
# pacman -Sy
# reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
# pacman -S git
# git clone https://github.com/MetalYos/Arch-Linux-Files.git
# chmod 777 Arch-Linux-Files/vbox_install_arch.sh
# ./Arch-Linux-Files/vbox_install_arch

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

hostname=''
username=''
password=''

function CreatePartitions() {
	# Partition disk
	echo -e "${BYellow}[ * ]Paritioning the disk${End_Colour}"
	sgdisk -o /dev/sda
	sgdisk -n 1:0:+1G -n 2:0:+4G -n 3:0:+10G -n 4:0:0 /dev/sda
	sgdisk -t 1:EF00 -t 2:8200 -t 3:8304 -t 4:8302

	# Format partitions
	echo -e "${BYellow}[ * ]Format the partitions${End_Colour}"
	mkfs.fat -F32 /dev/sda1
	mkswap /dev/sda2
	mkfs.ext4 /dev/sda3
	mkfs.ext4 /dev/sda4

	# Mount partitions
	echo -e "${BYellow}[ * ]Mount the partitions${End_Colour}"
	swapon /dev/sda2
	mount /dev/sda3 /mnt
	mkdir /mnt/{boot,home}
	mount /dev/sda1 /mnt/boot
	mount /dev/sda4 /mnt/home
}

function UpdateSystemClock() {
	# Update the system clock
	echo -e "${BYellow}[ * ]Update the system clock${End_Colour}"
	timedatectl set-ntp true
}

function InstallArchBase() {
	# Install Arch packages
	echo -e "${BYellow}[ * ]Install Arch packages${End_Colour}"
	pacstrap /mnt base base-devel linux linux-firmware linux-headers
}

function GenerateFStab() {
	# Generate fstab file
	echo -e "${BYellow}[ * ]Generate fstab file${End_Colour}"
	genfstab -U /mnt >> /mnt/etc/fstab
}

function RunChRoot() {
    mv PostInstall /mnt/PostInstall
    arch-chroot /mnt bash "PostInstall/post_install.sh" $1 $2 $3
    rm -rf /mnt/PostInstall
}

function CleanUp() {
	# Echo exit chroot and unmount partitions
	echo -e "${BYellow}[ * ]Unmounting partitions${End_Colour}"
	umount -R /mnt
	swapoff /dev/sda2
}

function MainMenu() {
	echo "Welcome to Yossi's Arch Linux installation script"
	read -p 'Hostname: ' hostname
	read -p 'Username: ' username
	read -sp 'Password: ' password

	echo Starting installation... Good Luck!
}

function Main() {
	MainMenu
	CreatePartitions
	UpdateSystemClock
	InstallArchBase
	GenerateFStab
	RunChRoot hostname username password
	CleanUp
	
	echo -e "${BGreen}Setup Completed !! Reboot Your Machine${End_Colour}"
}

Main