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

# Update the system clock
echo -e "${BYellow}[ * ]Update the system clock${End_Colour}"
timedatectl set-ntp true

# Install Arch packages
echo -e "${BYellow}[ * ]Install Arch packages${End_Colour}"
pacstrap /mnt base base-devel openssh linux linux-firmware neovim

# Generate fstab file
echo -e "${BYellow}[ * ]Generate fstab file${End_Colour}"
genfstab -U /mnt >> /mnt/etc/fstab

# Enter the new system
arch-chroot /mnt

# Language-related settings
echo -e "${BYellow}[ * ]Language-related settings${End_Colour}"
arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
arch-chroot /mnt locale-gen

arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
arch-chroot /mnt echo LANGUAGE=en_US >> /etc/locale.conf
arch-chroot /mnt echo LC_ALL=C >> /etc/locale.con

arch-chroot /mnt echo KEYMAP=us > /etc/vconsole.conf

# Configure timezone
echo -e "${BYellow}[ * ]Configure timezone${End_Colour}"
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Israel /etc/localtime
arch-chroot /mnt hwclock —-systohc

# Enabling parallel downloads for pacman
echo -e "${BYellow}[ * ]Enabling parallel downloads for pacman${End_Colour}"
arch-chroot /mnt sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 5/g" /etc/pacman.conf

# Enable SSH, NetworkManager and DHCP
echo -e "${BYellow}[ * ]Enable SSH, NetworkManager and DHCP${End_Colour}"
arch-chroot /mnt pacman -S dhcpcd networkmanager network-manager-applet
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable NetworkManager

# Install bootloader
echo -e "${BYellow}[ * ]Install bootloader${End_Colour}"
arch-chroot /mnt pacman -S grub-efi-x86_64 efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Choose a name for your computer (TODO: make this a script argument)
echo -e "${BYellow}[ * ]Choose a name for your computer${End_Colour}"
arch-chroot /mnt echo arch-i3 > /etc/hostname

# Adding content to the hosts file
echo -e "${BYellow}[ * ]Adding content to the hosts file${End_Colour}"
arch-chroot /mnt echo 127.0.0.1		localhost.localdomain		localhost >> /etc/hosts
arch-chroot /mnt echo ::1			localhost.localdomain		localhost >> /etc/hosts
arch-chroot /mnt echo 127.0.0.1		arch-i3.localdomain			arch-i3 >> /etc/hosts

# Install other useful packages
echo -e "${BYellow}[ * ]Install other useful packages${End_Colour}"
arch-chroot /mnt pacman -S iw wpa_supplicant dialog intel-ucode lshw unzip htop wget pulseaudio alsa-utils alsa-plugins pavucontrol xdg-user-dirs

# Creating password for the root user
echo -e "${BYellow}[ * ]Enter root password${End_Colour}"
arch-chroot /mnt passwd

# Add user
echo -e "${BYellow}[ * ]Add user${End_Colour}"
arch-chroot /mnt useradd -m -g users -G wheel,storage,power,audio yossi

# Creating password for the new user
echo -e "${BYellow}[ * ]Enter new user password${End_Colour}"
arch-chroot /mnt passwd

# Giving user sudo privileges
echo -e "${BYellow}Giving user sudo privileges[ * ]${End_Colour}"
arch-chroot /mnt sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

# Manage Bluetooth
echo -e "${BYellow}Manage Bluetooth[ * ]${End_Colour}"
arch-chroot /mnt pacman -S bluez bluez-utils blueman
arch-chroot /mnt systemctl enable bluetooth

# Echo exit chroot and unmount partitions
echo -e "${BYellow}[ * ]Unmounting partitions${End_Colour}"
arch-chroot /mnt exit
umount -R /mnt
swapoff /dev/sda2

echo -e "${BGreen}Setup Completed !! Reboot Your Machine${End_Colour}"