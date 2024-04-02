# Arch Linux installation

> This is an **opinionated** way of installing a minimal version of Arch Linux.

Additional configuration is made with Ansible.

Source of truth [Arch wiki](https://wiki.archlinux.org/)

# Installation

> **WARNING** Selected disk will be wiped and all data will be lost.

1. Disable Secure Boot
2. Boot with arch.iso
3. Run `base.sh`
    - This will in turn run `chroot.sh`

Now you have a base installation Arch Linux that is bootable.

**Optional (Recommended)**

If you wish to enable `Secure Boot`, reboot you system and put secure boot into
`setup mode`

4. run `secure_boot.sh`
5. reboot and verify with `sbctl status` that secure boot is enabled

# Requirements

- UEFI

# Design decisions

- Partitioning (LVM)
  - /efi
  - /root (Encrypted)
  - swap (Encrypted)

- Encryption
  - LUKS1

- Secure boot
  - sbctl
  - All vendor keys removed (**WARNING** make sure you understand impact of
    this)

- Bootloader
  - grub
