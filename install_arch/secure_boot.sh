#!/bin/bash

# Before running this script clear vendor keys and put secure boot in "Setup mode"

# Colors
BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

# Check if user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Check for UEFI mode
if [ ! -d /sys/firmware/efi/efivars ]; then
    echo "UEFI not detected. Secure Boot requires UEFI."
    exit 1
fi

echo -e "${BBlue}Grub install with secureboot options ${NC}"
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock

echo -e "${BBlue}Install sbctl ${NC}"
pacman -S sbctl --noconfirm

echo -e "${BBlue}sbctl status ${NC}"
sbctl status

echo -e "${BBlue}sbctl create-keys ${NC}"
sbctl create-keys

echo -e "${BBlue}sbctl enroll-keys ${NC}"
sbctl enroll-keys --yes-this-might-brick-my-machine # --yolo

echo -e "${BBlue}sbctl status ${NC}"
sbctl status

echo -e "${BBlue}sbctl sign ${NC}"
sbctl sign -s /boot/vmlinuz-linux
sbctl sign -s /efi/EFI/GRUB/grubx64.efi

printf "Secure boot setup completed now verify secureboot is activated in UEFI firmware setup \n\t%s\n" "systemctl reboot --firmware"
printf "Make sure to password protect firmware setup, aka BIOS \nAt next boot run \n\t%s\n" "sbctl status"
