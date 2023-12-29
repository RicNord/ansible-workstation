#!/bin/bash

# Fail on any non-zero exit code
set -eo pipefail

BBlue='\033[1;34m'
NC='\033[0m' # NO COLOR

UUID=$(uuidgen)
ANSIBLE_VENV_PATH="/tmp/.ansible-venv/$UUID"

echo -e "${BBlue}Create viritual enviormant at: $ANSIBLE_VENV_PATH ${NC}"
python -m venv "$ANSIBLE_VENV_PATH"
source "$ANSIBLE_VENV_PATH/bin/activate"

echo -e "${BBlue}Pip install requirements ${NC}"
pip install -r ./requirements.txt

echo -e "${BBlue}Ansible galaxy install ${NC}"
ansible-galaxy install -r ansible_galaxy.yaml

echo -e "${BBlue}Run ansible playbook ${NC}"
ansible-playbook main.yaml -K
