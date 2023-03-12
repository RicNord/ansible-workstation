# Pre-requisits for arch workstation
Source of truth
[Arch wiki](https://wiki.archlinux.org/)

## Follow [installation guide](https://wiki.archlinux.org/title/Installation_guide)
## Choices/Deviations

### Set Stockholm timezone
```shell
timedatectl set-timezone Europe/Stockholm
```

### Extra packages
```shell
pacstrap -K /mnt base linux-lts linux-firmware base-devel gvim
```
if gpg keys invalid run
```shell
pacman -Sy archlinux-keyring
```

### NetworkManager
```shell
pacman -S networkmanager

# enable service
systemctl enable NetworkManager
```

### Bootloader
```shell
pacman -S grub efibootmgr

## TODO install load microcode `pacman -S {amd,intel}-ucode` based on manufacturer

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg
```

To detect other OS in `grub-mkconfig` uncomment in `/etc/default/grub`

```shell
GRUB_DISABLE_OS_PROBER=false
```
Install os-prober
> pacman -S os-prober

Mount partition other OS is installed on and regenerate
```shell
mount /dev/<other os partition> /mnt

grub-mkconfig -o /boot/grub/grub.cfg

```

## Reboot and unplug install-medium
