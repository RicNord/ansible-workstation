# Ansible project for personal Workstations
## Supported platforms
- Arch (btw)
- Ubuntu

> Current `inventory` file use localhost as target system

## Usage
If this is the first time you clone the repo and you did not use 
`git clone --recurse-submodules`, then you need to run 
`git submodule update --init --recursive` to initialize fetch and checkout submodules.

Default User created in the set-up is `nord`, this can be changed in the 
`group_vars/workstations.yaml` file.

Then:
- Create and activate a virtual env (optional)
- Run `bash install-dependencies.sh`
- Run `ansible-playbook main.yaml -K`
    - Provide sudo password on target system
