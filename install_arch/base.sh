#!/bin/bash

# Colors
BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

# Check if user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Take action if UEFI is supported.
if [ ! -d "/sys/firmware/efi/efivars" ]; then
    echo -e "${BBlue}UEFI is not supported.${NC}"
    exit 1
else
    echo -e "${BBlue}\n UEFI is supported, proceeding...\n${NC}"
fi
#
# Get user input for the settings
echo -e "${BBlue}The following disks are available on your system:\n${NC}"
lsblk -d | grep -v 'rom' | grep -v 'loop'
echo -e "\n"

read -rp 'WARNING ALL CURRENT DATA ON THIS DISK WILL BE LOST. Select the target disk: ' TARGET_DISK
echo -e "\n"

echo -e "${BBlue}Set / and Swap partition size:\n${NC}"

read -rp 'Enter the size of SWAP in GB: ' SIZE_OF_SWAP
echo -e "\n"

# Use the correct variable name for the target disk
DISK="/dev/$TARGET_DISK"
SWAP_SIZE="${SIZE_OF_SWAP}G"
CRYPT_NAME="cryptlvm"

timedatectl set-timezone Europe/Stockholm
timedatectl set-ntp true

echo -e "${BBlue}wipefs $DISK\n${NC}"
wipefs --all "$DISK"

echo -e "${BBlue}clear partition table $DISK\n${NC}"
sgdisk --clear --mbrtogpt "$DISK"

echo -e "${BBlue}Create a 1MiB BIOS boot partition $DISK\n${NC}"
sgdisk --new=1:2048:4095 --typecode=1:ef02 "$DISK"

echo -e "${BBlue}Create a UEFI partition $DISK\n${NC}"
sgdisk --new=2:4096:1130495 --typecode=2:ef00 "$DISK"

echo -e "${BBlue}Create a LUKS partition $DISK\n${NC}"
sgdisk --new=3:1130496:"$(sgdisk --end-of-largest "$DISK")" --typecode=3:8309 "$DISK"

echo -e "${BBlue}Encrypt LUKS partition $DISK\n${NC}"
cryptsetup luksFormat -q --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 3000 --use-random --type luks1 "${DISK}p3"

echo -e "${BBlue}Open LUKS partition $DISK\n${NC}"
cryptsetup -v luksOpen "${DISK}p3" "$CRYPT_NAME"

echo -e "${BBlue}Create Pysical volume, volume group, logical volumes $DISK\n${NC}"
pvcreate --verbose /dev/mapper/"$CRYPT_NAME"
vgcreate --verbose vg /dev/mapper/"$CRYPT_NAME"
lvcreate --verbose -L "$SWAP_SIZE" vg -n swap
lvcreate --verbose -l 100%FREE vg -n root

echo -e "${BBlue}Make filesystems root and swap $DISK\n${NC}"
mkfs.ext4 /dev/vg/root
mkswap /dev/vg/swap

echo -e "${BBlue}Mount filesystems root and swap $DISK\n${NC}"
mount --verbose /dev/vg/root /mnt
swapon /dev/vg/swap

echo -e "${BBlue}Make filesystem efi and mount $DISK\n${NC}"
mkfs.fat -F32 /dev/"$DISK"p2
mkdir --verbose /mnt/efi
mount --verbose /dev/"$DISK"p2 /mnt/efi

echo -e "${BBlue}Get archlinux-keyring $DISK\n${NC}"
pacman -Sy archlinux-keyring --noconfirm

echo -e "${BBlue}Pacstrap $DISK\n${NC}"
pacstrap /mnt base linux linux-firmware base-devel mkinitcpio lvm2 networkmanager gvim git archlinux-keyring

echo -e "${BBlue}genfstab $DISK\n${NC}"
genfstab -pU /mnt >>/mnt/etc/fstab

echo -e "${BBlue}arch-chroot /mnt and execute ./chroot.sh $DISK\n${NC}"
# CHROOT!
cp ./chroot.sh /mnt \
    && chmod +x /mnt/chroot.sh

arch-chroot /mnt /bin/bash ./chroot.sh "$DISK"
