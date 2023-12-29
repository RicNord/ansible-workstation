#!/bin/bash

DISK=$1

# Colors
BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

# Check if user is root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

echo -e "${BBlue}Choosing a hostname:\n${NC}"

read -rp 'Enter the new hostname: ' NEW_HOST
echo -e "\n"

echo -e "${BBlue}Set timezone and locale-gen${NC}"
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc

sed -i '/#en_US.UTF-8/s/^#//g' /etc/locale.gen \
    && locale-gen \
    && echo 'LANG=en_US.UTF-8' >/etc/locale.conf \
    && export LANG=en_US.UTF-8

echo -e "${BBlue}Set hostname${NC}"
echo "$NEW_HOST" >/etc/hostname

echo -e "${BBlue}Creating the LUKS key for $DISK ${NC}"
LUKS_KEYS=/root/secrets/crypto_keyfile.bin

mkdir /root/secrets && chmod 700 /root/secrets
head -c 64 /dev/urandom >"$LUKS_KEYS" && chmod 600 "$LUKS_KEYS"
cryptsetup -v luksAddKey -i 1 "$DISK"p3 "$LUKS_KEYS"

echo -e "${BBlue}Adjust /etc/mkinitcpio.conf for encryption ${NC}"
sed -i "s|^HOOKS=.*|HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)|g" /etc/mkinitcpio.conf
sed -i "s|^FILES=.*|FILES=(${LUKS_KEYS})|g" /etc/mkinitcpio.conf

echo -e "${BBlue}Install ucode for CPU ${NC}"
CPU_VENDOR_ID=$(lscpu | grep Vendor | awk '{print $3}')
# Use grep to check if the string 'Intel' is present in the CPU info
if [[ $CPU_VENDOR_ID =~ "GenuineIntel" ]]; then
    pacman -S intel-ucode --noconfirm
elif
    # If the string 'Intel' is not present, check if the string 'AMD' is present
    [[ $CPU_VENDOR_ID =~ "AuthenticAMD" ]]
then
    pacman -S amd-ucode --noconfirm
else
    # If neither 'Intel' nor 'AMD' is present, then it is an unknown CPU
    echo "This is an unknown CPU."
fi

echo -e "${BBlue}mkinitcpio ${NC}"
mkinitcpio -p linux

echo -e "${BBlue}GRUB set-up ${NC}"
pacman -S grub efibootmgr

UUID=$(cryptsetup luksDump "${DISK}p3" | grep UUID | awk '{print $2}')
GRUBCMD="\"cryptdevice=UUID=$UUID:cryptlvm root=/dev/vg/root cryptkey=rootfs:$LUKS_KEYS\""
sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=${GRUBCMD}|g" /etc/default/grub
sed -i '/GRUB_ENABLE_CRYPTODISK/s/^#//g' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

chmod 700 /boot
