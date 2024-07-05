#!/bin/bash

# Before running this script you need to run the following commands manually
# pacman -Sy
# reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
# pacman -S git
# git clone https://github.com/MetalYos/Arch-Linux-Files.git
# cd into Arch-Linux-Files
# chmod 777 Arch-Linux-Files/install.sh
# ./Arch-Linux-Files/install

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
# BBlue="\e[1;34m"
End_Colour="\e[0m"

# Defaults
HD_DEVICE_DEFAULT="nvme0n1"
HOSTNAME_DEFAULT="ArchYos"
USERNAME_DEFAULT="yossi"
WIFI_STATION_DEFAULT="wlan0"
WIFI_SSID_DEFAULT="yossico-net"

hd_device=''
hostname=''
username=''
password=''
boot_part=''
swap_part=''
root_part=''

function LoadKeys() {
	loadkeys en
}

function UpdateSystemClock() {
	# Update the system clock
	echo -e "${BYellow}[ * ]Update the system clock${End_Colour}"
	timedatectl set-ntp true
}

function SetupPacman() {
	# Enabling parallel downloads for pacman
	echo -e "${BYellow}[ * ]Enabling parallel downloads for pacman${End_Colour}"
	sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 20/g" /etc/pacman.conf
	# Enabling color for pacman
	echo -e "${BYellow}[ * ]Enabling color for pacman${End_Colour}"
	sed -i "s/#Color/Color/g" /etc/pacman.conf
	echo -e "${BYellow}[ * ]Enabling multilib (lib32 packages) for pacman${End_Colour}"
	sed -i "s/#\[multilib\]/\[multilib\]/" /etc/pacman.conf
	tac /etc/pacman.conf | sed "0,/#Include/ s//Include/" | tac > pacman.conf
	mv pacman.conf /etc/pacman.conf
}

function CreatePartitions() {
	# Unmount mnt folder in case it is mounted
	umount -R /mnt

	# Turn off swap in case it is on
	swapoff /dev/${swap_part}

	# Delete parition table in case it is there
	blkdiscard /dev/${hd_device} -v -f

	# Partition disk
	echo -e "${BYellow}[ * ]Paritioning the ${hd_device} device${End_Colour}"
	sgdisk -Z /dev/${hd_device}
	sgdisk -o /dev/${hd_device}
	sgdisk -n 1:0:+512M -n 2:0:+16G -n 3:0:0 /dev/${hd_device}
	sgdisk -t 1:EF00 -t 2:8200 -t 3:8300

	# Format partitions
	echo -e "${BYellow}[ * ]Format the partitions${End_Colour}"
	echo -e "${BYellow}[ * ]Creating fat32 filesystem on ${boot_part}${End_Colour}"
	mkfs.fat -F32 /dev/${boot_part}
	echo -e "${BYellow}[ * ]Creating Swap partition on ${swap_part}${End_Colour}"
	mkswap /dev/${swap_part}
	swapon /dev/${swap_part}
	echo -e "${BYellow}[ * ]Creating btrf filesystem on ${root_part}${End_Colour}"
	mkfs.btrfs /dev/${root_part}

	# Create btrfs subvolumes
	mount /dev/${root_part} /mnt
	btrfs su cr /mnt/@
	btrfs su cr /mnt/@home
	btrfs su cr /mnt/@root
	btrfs su cr /mnt/@srv
	btrfs su cr /mnt/@log
	btrfs su cr /mnt/@cache
	btrfs su cr /mnt/@tmp

	echo -e "${BYellow}[ * ]Created the following btrfs subvolumes${End_Colour}"
	btrfs su li /mnt
	sleep 3

	# Unmount
	umount /mnt
}

function MountPartitions() {
	# Mount partitions
	# Btrfs options:
	#   noatime – No access time. Improves system performace by not writing time when the file was accessed.
	#   commit – Periodic interval (in sec) in which data is synchronized to permanent storage.
	#   compress – Choosing the algorithm for compress. I have set zstd as it has good compression level and speed.
	#   subvol – Choosing the subvol to mount.
	echo -e "${BYellow}[ * ]Mount the partitions${End_Colour}"
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ /dev/${root_part} /mnt
	mkdir -p /mnt/{home,root,srv,var/log,var/cache,tmp}
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@home /dev/${root_part} /mnt/home
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@root /dev/${root_part} /mnt/root
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@srv /dev/${root_part} /mnt/srv
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@log /dev/${root_part} /mnt/var/log
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@cache /dev/${root_part} /mnt/var/cache
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@tmp /dev/${root_part} /mnt/tmp
	mkdir -p /mnt/boot/efi
	mount /dev/${boot_part} /mnt/boot/efi
}

function InstallArchBase() {
	# Install Arch packages
	echo -e "${BYellow}[ * ]Install Arch packages${End_Colour}"
	pacstrap -K /mnt base base-devel linux linux-firmware linux-headers btrfs-progs vim nano
}

function GenerateFStab() {
	# Generate fstab file
	echo -e "${BYellow}[ * ]Generate fstab file${End_Colour}"
	genfstab -U /mnt >> /mnt/etc/fstab
}

function RunPostInstall() {
	cp -r PostInstall /mnt
	echo -e "${BYellow}[ * ]Running root Post Install script${End_Colour}"
	arch-chroot /mnt bash "PostInstall/root_post_install.sh" "${1}" "${2}" "${3}"
	echo -e "${BYellow}[ * ]Running ${2} Post Install script${End_Colour}"
	arch-chroot /mnt sudo -u ${2} bash "PostInstall/user_post_install.sh" "${2}" "${3}"
	rm -rf /mnt/PostInstall
}

function CleanUp() {
	# Echo exit chroot and unmount partitions
	echo -e "${BYellow}[ * ]Unmounting partitions${End_Colour}"
	swapoff /dev/${swap_part}
	umount -R /mnt
}

function MainMenu() {
	echo "Welcome to Yossi's Arch Linux installation script"
	read -p "Hard Disk Device Name (${HD_DEVICE_DEFAULT}): " hd_device
	hd_device="${hd_device:-$HD_DEVICE_DEFAULT}"
	read -p "Hostname (${HOSTNAME_DEFAULT}): " hostname
	hostname="${hostname:-$HOSTNAME_DEFAULT}"
	read -p "Username (${USERNAME_DEFAULT}): " username
	username="${username:-$USERNAME_DEFAULT}"
	read -sp "Password: " password
	echo

	read -p 'Connect to WIFI network (y/n): ' con_wifi
	if [[ "$con_wifi" == "y" ]]; then
		read -p "WIFI station name (${WIFI_STATION_DEFAULT}): " wifi_station
		wifi_station="${wifi_station:-$WIFI_STATION_DEFAULT}"
		read -p "network name (${WIFI_SSID_DEFAULT}): " wifi_ssid
		wifi_ssid="${wifi_ssid:-$WIFI_SSID_DEFAULT}"
		read -sp "network password: " wifi_pass
		echo

		echo -e "${BYellow}[ * ]Connecting to wifi network ${network_name}...${End_Colour}"
		iwctl --passphrase ${wifi_pass} station ${wifi_station} connect ${wifi_ssid}
		sleep 3
		iwctl --passphrase ${wifi_pass} station ${wifi_station} connect ${wifi_ssid}
		sleep 3
	fi

	if [[ "$hd_device" == *"sd"* ]]; then
		boot_part="${hd_device}1"
		swap_part="${hd_device}2"
		root_part="${hd_device}3"
	else
		boot_part="${hd_device}p1"
		swap_part="${hd_device}p2"
		root_part="${hd_device}p3"
	fi

	echo Starting installation... Good Luck!
}

function Main() {
	MainMenu
	LoadKeys
	UpdateSystemClock
	SetupPacman
	CreatePartitions
	MountPartitions
	InstallArchBase
	GenerateFStab
	RunPostInstall "${hostname}" "${username}" "${password}"
	CleanUp
	echo -e "${BGreen}Setup Completed !! Reboot Your Machine${End_Colour}"
}

Main
