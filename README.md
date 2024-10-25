# Ansible project for personal Workstations

## Supported platforms

- Arch (btw)
- Ubuntu
  - Included in test suite
    - 24.04
    - 22.04

**NOTE:** Arch Linux is currently the primarily maintained option.

## Scope

This projects intends to configure everything for a complete end-user
experience. It only assumes that a bare-minimum and bootable systemd based
distribution of Linux already exists. Included in the Ansible roles are (but
**not limited** too):

- Create user (added to the `sudo` group and the user which all opinionated
  configurations will be applied for)
- Install Dotfiles
- Installation of notable software:
  - Programming languages / runtimes
    - Python
    - Go
    - Rust
    - Lua
    - Java
    - Dotnet
    - Node
  - Neovim with LSP support
  - Networkmanager
  - Pulseaudio
  - (+) Lots of popular cli tools
- (*optional*) graphical environment support with Xorg
  - Suckless software
    - dwm (dynamic window manager)
    - slock (screen locker)
    - slstatus (status bar)
    - dmenu
  - Browser etc.

## Usage

> The [inventory](./inventory) file uses `localhost` as the target system.

Default run command for all Ansible roles:

```bash
make install
```

The playbooks will identify and run appropriate tasks depending on the host
platform. However, if you do not need a graphical environment and `X11` on the
target host; you have the option to exclude installing these dependencies with:

```bash
# Native installer
./run-ansible.sh -x false

# Or manually
ansible-playbook --ask-become-pass --skip-tags=X main.yaml
```

Default User created in the set-up is `nord`, this can be changed in the
[group_vars/workstations.yaml](./group_vars/workstations.yaml) file.

### Install arch

See arch installation [README](./install_arch/README.md).

## Dependencies

- python
- git
- make

[Tests]

- incus
- terraform
- parallel

## Development

*Optionally* use `pipenv` to manage python environment.

### Tests

Complete test suite:

```bash
make test
```

See [tests](./tests/) for more granular test runner.
