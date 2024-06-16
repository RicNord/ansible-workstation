# Ansible project for personal Workstations

## Supported platforms

- Arch (btw)
- Ubuntu
  - Included in test suite
    - 24.04
    - 22.04

> Current [inventory](./inventory) file use `localhost` as target system

**NOTE:** Arch linux is currently the primarily maintained option.

## Usage

Default run command for all Ansible roles:

```bash
make install
```

The playbooks will identify and run appropriate tasks depending on host
platform. However, if you do not need a graphical environment and `X11` on the
target host; you have the option exclude installing these dependencies with:

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
