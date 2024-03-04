#!/bin/bash

cd ./terraform/ && terraform apply -auto-approve
incus exec --project ansible-ws arch-vm -- bash -c "pacman -S --noconfirm git base-devel reflector"
incus exec --project ansible-ws arch-vm -- bash -c "reflector --delay 3 -c 'se,dk,no,fi,ge,nl' -f 20 --sort=rate -p https --save '/etc/pacman.d/mirrorlist'"
incus exec --project ansible-ws arch-vm -- bash -c "cd /tmp \
    && git clone --shallow-submodules --recurse-submodules --depth 1 https://github.com/ricnord/ansible-workstation \
    ; cd ansible-workstation \
    && make install"
