# Ansible project for personal Workstations
## Supported platforms
- Arch (btw)
- Ubuntu

> Current [inventory](.inventory) file use `localhost` as target system

## Usage
If this is the first time you clone the repo and you did not use
`git clone --recurse-submodules`, then you need to run
`git submodule update --init --recursive` to initialize fetch and checkout submodules.

Default User created in the set-up is `nord`, this can be changed in the
[group_vars/workstations.yaml](./group_vars/workstations.yaml) file.

### Install arch

See arch installation [README](./install_arch/README.md).

### Run ansible playbooks

`make install`

## Development

*Optionally* use `pipenv` to manage python enviorment.
