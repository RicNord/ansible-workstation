# Arch Linux installation

> This is an **opinionated** way of installing a minimal version of Arch Linux.

Additional configuration is made with Ansible.

Source of truth [Arch wiki](https://wiki.archlinux.org/)

# Pre-req

For wifi:

```bash
iwctl

# inside prompt
station <device-eg.wlan0> connect <name-of-wifi>

exit
```

Dependencies:

- `pacman -Sy git`
- `git clone http://github.com/RicNord/ansible-workstation`
- `cd ansible-workstation/install_arch`

# Installation

> **WARNING** Selected disk will be wiped and all data will be lost.

1. Disable Secure Boot
2. Boot with arch.iso
3. Run `bash base.sh`
    - This will in turn run `chroot.sh`

Now you have a base installation of Arch Linux that is bootable.

> Note: Some lenovo laptops need `sof-firmware` for sound to work properly

**Optionally enable Secure Boot (Recommended)**

If you wish to enable `Secure Boot`, reboot you system. Open UEFI and put
secure boot into `setup mode`. Now boot from GRUB. Connect to network eg.
`systemctl start --now NetworkManager`. And use `nmtui` to select network.

4. Clone this repo
5. Run `secure_boot.sh`
6. Reboot and verify with `sbctl status` that secure boot is enabled

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
