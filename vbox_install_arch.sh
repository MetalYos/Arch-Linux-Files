# Before running this script you need to run the following commands manually
# pacman -Sy
# reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
# pacman -S git
# git clone https://github.com/MetalYos/Arch-Linux-Files.git
# chmod 777 Arch-Linux-Files/vbox_install_arch.sh
# ./Arch-Linux-Files/vbox_install_arch

# Partition disk
sgdisk -o /dev/sda
sgdisk -n 1:0:+1G -n 2:0:+4G -n 3:0:+10G -n 4:0:0 /dev/sda
sgdisk -t 1:EF00 -t 2:8200 -t 3:8304 -t 4:8302

# Format partitions
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

# Mount partitions
swapon /dev/sda2
mount /dev/sda3 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
mount /dev/sda4 /mnt/home

# Update the system clock
timedatectl set-ntp true

# Install Arch packages
pacstrap /mnt base base-devel openssh linux linux-firmware neovim

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Enter the new system
arch-chroot /mnt

# Language-related settings
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf
echo LANGUAGE=en_US >> /etc/locale.conf
echo LC_ALL=C >> /etc/locale.con

echo KEYMAP=us > /etc/vconsole.conf

# Configure timezone
ln -sf /usr/share/zoneinfo/Israel /etc/localtime
hwclock —-systohc

# Enable SSH, NetworkManager and DHCP
pacman -S dhcpcd networkmanager network-manager-applet
systemctl enable sshd
systemctl enable dhcpcd
systemctl enable NetworkManager

# Install bootloader
pacman -S grub-efi-x86_64 efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Choose a name for your computer (TODO: make this a script argument)
echo arch-i3 > /etc/hostname

# Adding content to the hosts file
echo 127.0.0.1		localhost.localdomain		localhost >> /etc/hosts
echo ::1			localhost.localdomain		localhost >> /etc/hosts
echo 127.0.0.1		arch-i3.localdomain			arch-i3 >> /etc/hosts

# Install other useful packages
pacman -S iw wpa_supplicant dialog intel-ucode lshw unzip htop wget pulseaudio alsa-utils alsa-plugins pavucontrol xdg-user-dirs