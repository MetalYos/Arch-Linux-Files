#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
BBlue="\e[1;34m"
End_Colour="\e[0m"

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

function ConfigureTimezone() {
	# Configure timezone
	echo -e "${BYellow}[ * ]Configure timezone${End_Colour}"
	ln -sf /usr/share/zoneinfo/Israel /etc/localtime
	hwclock --systohc
}

function SetupLocale() {
	# Language-related settings
	echo -e "${BYellow}[ * ]Language-related settings${End_Colour}"
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sed -i 's/#he_IL.UTF-8 UTF-8/he_IL.UTF-8 UTF-8/g' /etc/locale.gen
	locale-gen

	echo LANG=en_US.UTF-8 > /etc/locale.conf
	echo KEYMAP=us > /etc/vconsole.conf
}

function ConfigureHostname() {
	local hostname="${1}"

	# Choose a name for your computer (TODO: make this a script argument)
	echo -e "${BYellow}[ * ]Setting ${hostname} for your computer hostname${End_Colour}"
	echo ${hostname} > /etc/hostname
	
	# Adding content to the hosts file
	echo -e "${BYellow}[ * ]Adding content to the hosts file${End_Colour}"
	echo 127.0.0.1		localhost >> /etc/hosts
	echo ::1			localhost >> /etc/hosts
	echo 127.0.0.1		${hostname}.localdomain			${hostname} >> /etc/hosts
}

function EnableNetworkServices() {
	# Enable SSH, NetworkManager and DHCP
	echo -e "${BYellow}[ * ]Enable SSH, NetworkManager and DHCP${End_Colour}"
	pacman -S dhcpcd networkmanager network-manager-applet iwd --noconfirm
	systemctl enable sshd
	systemctl enable dhcpcd
	systemctl enable NetworkManager
}

function EnableBluetooth() {
	# Manage Bluetooth
	echo -e "${BYellow}Enable Bluetooth[ * ]${End_Colour}"
	pacman -S bluez bluez-utils blueman --noconfirm
	systemctl enable bluetooth
}

function ConfigureBootloader() {
	# Install bootloader
	echo -e "${BYellow}[ * ]Install bootloader${End_Colour}"
	pacman -S grub-efi-x86_64 efibootmgr grub-btrfs inotify-tools timeshift --noconfirm
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg

	# Add timeshift support to grub
	sed -i "s/\/\.snapshots/--timeshift-auto/" /usr/lib/systemd/system/grub-btrfsd.service

	# Enable grub-btrfsd
	systemctl enable grub-btrfsd
}

function SetupUser() {
	local username="${1}"
	local password="${2}"

	# Creating password for the root user
	echo -e "${BYellow}[ * ]Setting password for root user${End_Colour}"
	# usermod --password ${password} root
	echo "${password}" | passwd --stdin root

	# Add user
	echo -e "${BYellow}[ * ]Add user ${username}${End_Colour}"
	useradd -m -g users -G wheel,storage,power,audio,video,network,rfkill -s /bin/bash ${username}

	# Creating password for the new user
	echo -e "${BYellow}[ * ]Set password for user ${username}${End_Colour}"
	echo "${username}:${password}" | chpasswd

	# Giving user sudo privileges
	echo -e "${BYellow}Giving user sudo privileges[ * ]${End_Colour}"
	sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

	# Create user dirs
	echo -e "${BYellow}Creating XDG user directories[ * ]${End_Colour}"
	pacman -S xdg-user-dirs --noconfirm
	su - ${username} -c xdg-user-dirs-update
}

function Main() {
	SetupPacman
	SetupLocale
	ConfigureTimezone
	ConfigureHostname "${1}"
	EnableNetworkServices
	EnableBluetooth
	ConfigureBootloader
	SetupUser "${2}" "${3}"
}

Main "$@"
