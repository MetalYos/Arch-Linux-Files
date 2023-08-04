#!/bin/bash

# Defining colours
BRed="\e[1;31m"
BGreen="\e[1;32m"
BYellow="\e[1;33m"
BBlue="\e[1;34m"
End_Colour="\e[0m"

function EnableParallelPacman() {
	# Enabling parallel downloads for pacman
	echo -e "${BYellow}[ * ]Enabling parallel downloads for pacman${End_Colour}"
	sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 5/g" /etc/pacman.conf
}

function SetupLanguage() {
	# Language-related settings
	echo -e "${BYellow}[ * ]Language-related settings${End_Colour}"
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	locale-gen

	echo LANG=en_US.UTF-8 > /etc/locale.conf
	echo LANGUAGE=en_US >> /etc/locale.conf
	echo LC_ALL=C >> /etc/locale.con

	echo KEYMAP=us > /etc/vconsole.conf
}

function ConfigureTimezone() {
	# Configure timezone
	echo -e "${BYellow}[ * ]Configure timezone${End_Colour}"
	ln -sf /usr/share/zoneinfo/Israel /etc/localtime
	hwclock —-systohc
}

function ConfigureHostname() {
	local hostname="${1}"

	# Choose a name for your computer (TODO: make this a script argument)
	echo -e "${BYellow}[ * ]Setting ${hostname} for your computer hostname${End_Colour}"
	echo ${hostname} > /etc/hostname
	
	# Adding content to the hosts file
	echo -e "${BYellow}[ * ]Adding content to the hosts file${End_Colour}"
	echo 127.0.0.1		localhost.localdomain		localhost >> /etc/hosts
	echo ::1			localhost.localdomain		localhost >> /etc/hosts
	echo 127.0.0.1		${hostname}.localdomain			${hostname} >> /etc/hosts
}

function ConfigureBootloader() {
	# Install bootloader
	echo -e "${BYellow}[ * ]Install bootloader${End_Colour}"
	pacman -S grub-efi-x86_64 efibootmgr --noconfirm
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
	grub-mkconfig -o /boot/grub/grub.cfg
}

function SetupUser() {
	local username="${1}"
	local password="${2}"

	# Creating password for the root user
	echo -e "${BYellow}[ * ]Setting password for root user${End_Colour}"
	usermod --password ${password} root

	# Add user
	echo -e "${BYellow}[ * ]Add user ${username}${End_Colour}"
	useradd -m -g users -G wheel,storage,power,audio ${username}

	# Creating password for the new user
	echo -e "${BYellow}[ * ]Set password for user ${username}${End_Colour}"
	echo "${username}:${password}" | chpasswd

	# Giving user sudo privileges
	echo -e "${BYellow}Giving user sudo privileges[ * ]${End_Colour}"
	sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

	# Create user dirs
	pacman -S xdg-user-dirs --noconfirm
	su - ${username} -c xdg-user-dirs-update
}

function EnableServices() {
	# Enable SSH, NetworkManager and DHCP
	echo -e "${BYellow}[ * ]Enable SSH, NetworkManager and DHCP${End_Colour}"
	pacman -S dhcpcd networkmanager network-manager-applet --noconfirm
	systemctl enable sshd
	systemctl enable dhcpcd
	systemctl enable NetworkManager
}

function EnableBluetooth() {
	# Manage Bluetooth
	echo -e "${BYellow}Manage Bluetooth[ * ]${End_Colour}"
	pacman -S bluez bluez-utils blueman --noconfirm
	systemctl enable bluetooth
}

function InstallVMachineGuestEditions() {
	local username="${1}"
	local vmach="${2}"

	if [ $vmach == 1 ]
	then
		# Install VMWare guest additions
		echo -e "${BYellow}[ * ]Install VMWare guest additions${End_Colour}"
		pacman -S open-vm-tools --noconfirm
		systemctl enable vmtoolsd.service
		systemctl enable vmware-vmblock-fuse.service
	elif [ $vmach == 2 ]
	then
		# Install VirtualBox guest additions
		echo -e "${BYellow}[ * ]Install VirtualBox guest additions${End_Colour}"
		pacman -S virtualbox-guest-utils --noconfirm
		systemctl enable vboxservice.service
		usermod -a -G vboxsf ${username}
	else
		echo -e "${BYellow}[ * ]Installed on a Physical Machine!${End_Colour}"
	fi
}

function InstallAdditionalPackages() {
	# Install other useful packages
	echo -e "${BYellow}[ * ]Install other useful packages${End_Colour}"
	pacman -S iw wpa_supplicant dialog intel-ucode lshw unzip htop wget pulseaudio alsa-utils alsa-plugins pavucontrol neovim openssh git gdb valgrind man --noconfirm
}

function Installi3() {
	cd PostInstall
	bash ./install_i3.sh "${1}"
	cd ..
}

function CopyConfigFiles() {
	local username="${1}"
	
	# Copy i3 config file
	echo -e "${BYellow}[ * ]Copy .config and .local folder${End_Colour}"
	cp -r .config /home/${username}/
	cp -r .local /home/${username}/

	# Change owner and group of local and config
	chown -R ${username}:users .config
	chown -R ${username}:users .local
}

function Main() {
	SetupLanguage
	ConfigureTimezone
	ConfigureHostname "${1}"
	ConfigureBootloader
	EnableParallelPacman
	SetupUser "${2}" "${3}"
	EnableServices
	EnableBluetooth
	InstallVMachineGuestEditions "${2}" "${4}"
	InstallAdditionalPackages
	Installi3 "${2}"
	CopyConfigFiles "${2}"
}

Main "$@"