# Partition disk
sgdisk -o /dev/sda
sgdisk -n 1:0:+1G -n 2:0:+4G -n 3:0:+10G -n 4:0:0 /dev/sda
sgdisk -t 1:EF00 -t 2:8200 -t 3:8304 -t 4:8302

# Format partitions
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
mkfs.ext4 /dev/sda5

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